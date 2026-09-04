#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -Eeuo pipefail

# Translates /data/options.json into CC_* env vars, then execs the upstream entrypoint.

OPTIONS_JSON="/data/options.json"
CONFIG_DIR="/config"
DEFAULT_STORAGE_PATH="/media/cataloguecanvas"

log() {
    echo "[cataloguecanvas] $*"
}

banner() {
    local os_name kernel

    if [[ -r /etc/os-release ]]; then
        os_name="$(. /etc/os-release 2> /dev/null && printf '%s' "${PRETTY_NAME:-unknown}")"
    else
        os_name="unknown"
    fi
    kernel="$(uname -srm 2> /dev/null || echo unknown)"

    cat << 'EOF'
 _____       _        _                          _____
/  __ \     | |      | |                        /  __ \
| /  \/ __ _| |_ __ _| | ___   __ _ _   _  ___  | /  \/ __ _ _ ____   ____ _ ___
| |    / _` | __/ _` | |/ _ \ / _` | | | |/ _ \ | |    / _` | '_ \ \ / / _` / __|
| \__/\ (_| | || (_| | | (_) | (_| | |_| |  __/ | \__/\ (_| | | | \ V / (_| \__ \
 \____/\__,_|\__\__,_|_|\___/ \__, |\__,_|\___|  \____/\__,_|_| |_|\_/ \__,_|___/
                               __/ |
                              |___/
EOF
    log "System status:"
    log "  add-on version : ${CC_ADDON_VERSION:-unknown}"
    log "  architecture   : ${CC_ADDON_ARCH:-$(uname -m)}"
    log "  os             : ${os_name}"
    log "  kernel         : ${kernel}"
}

die() {
    echo "[cataloguecanvas] ERROR: $*" >&2
    exit 1
}

read_opt() {
    local key="$1"
    jq -er --arg k "$key" '.[$k]' "$OPTIONS_JSON" 2> /dev/null || true
}

normalize_path() {
    local raw="$1"
    if command -v realpath > /dev/null 2>&1; then
        realpath -m "$raw"
        return
    fi

    case "$raw" in
        /*) printf '%s\n' "$raw" ;;
        *) printf '/%s\n' "$raw" ;;
    esac
}

is_allowed_path() {
    local resolved="$1"
    case "$resolved" in
        /share | /share/* | /media | /media/* | /config | /config/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

require_mapped_path() {
    local label="$1"
    local raw="$2"
    local resolved

    resolved="$(normalize_path "$raw")"
    if ! is_allowed_path "$resolved"; then
        die "${label} '${raw}' resolves to '${resolved}', which is outside /share, /media, and /config"
    fi

    printf '%s\n' "$resolved"
}

ensure_dir() {
    local dir="$1"
    mkdir -p "$dir"
}

ensure_existing_or_create() {
    local label="$1"
    local dir="$2"

    if [[ -d "$dir" ]]; then
        return
    fi

    if mkdir -p "$dir" 2> /dev/null; then
        return
    fi

    die "${label} '${dir}' does not exist and could not be created. Create it on the host or choose a writable path under /media, /share, or /config."
}

chown_recursive_if_writable() {
    local owner="$1"
    local path="$2"
    local current_owner

    if [[ ! -e "$path" ]]; then
        log "Skipping ownership update for ${path} (missing path)"
        return
    fi

    if [[ -w "$path" ]]; then
        if current_owner="$(stat -c '%u:%g' "$path" 2> /dev/null)"; then
            if [[ "$current_owner" == "$owner" ]]; then
                log "Skipping ownership update for ${path} (already owned by ${owner})"
                return
            fi
        fi
        chown -R "$owner" "$path"
        return
    fi

    log "Skipping ownership update for ${path} (read-only mapping)"
}

banner

[[ -f "$OPTIONS_JSON" ]] || die "Missing options file at ${OPTIONS_JSON}"

PUID="$(read_opt puid)"
PUID="${PUID:-1000}"
PGID="$(read_opt pgid)"
PGID="${PGID:-1000}"
STORAGE_PATH_RAW="$(read_opt storage_path)"
STORAGE_PATH_RAW="${STORAGE_PATH_RAW:-$DEFAULT_STORAGE_PATH}"

[[ "$PUID" =~ ^[0-9]+$ ]] || die "puid must be a non-negative integer"
[[ "$PGID" =~ ^[0-9]+$ ]] || die "pgid must be a non-negative integer"

CC_STORAGE_DIR="$(require_mapped_path "storage_path" "$STORAGE_PATH_RAW")"

ensure_dir "$CONFIG_DIR"
ensure_existing_or_create "storage_path" "$CC_STORAGE_DIR"

export CC_DATA_DIR="/config"
export CC_DB_PATH="/config/catalogue.db"
export CC_STORAGE_DIR

# Emit `export KEY=value` lines for each option (jq renders bools as true/false).
if ! exports="$(jq -er '
    def opt(k; env_key):
      if has(k) and .[k] != null and .[k] != "" then
        env_key + "=" + (.[k] | tostring)
      else empty end;
    [
      opt("admin_password"; "CC_ADMIN_PASSWORD"),
      opt("admin_username"; "CC_ADMIN_USERNAME"),
      opt("site_title"; "CC_SITE_TITLE"),
      opt("site_author"; "CC_SITE_AUTHOR"),
      opt("cookie_secure"; "CC_COOKIE_SECURE"),
      opt("llm_allowed_hosts"; "CC_LLM_ALLOWED_HOSTS"),
      opt("max_upload_bytes"; "CC_MAX_UPLOAD_BYTES")
    ] | .[]
  ' "$OPTIONS_JSON")"; then
    die "${OPTIONS_JSON} is not valid JSON"
fi

while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    export "${key}=${value}"
done <<< "$exports"

if [[ -z "${CC_ADMIN_PASSWORD:-}" ]]; then
    log "WARNING: admin_password is empty; the app fails closed (no admin login) until you set it in the add-on configuration."
fi

chown_recursive_if_writable "$PUID:$PGID" "$CONFIG_DIR"
chown_recursive_if_writable "$PUID:$PGID" "$CC_STORAGE_DIR"

log "Configuration summary:"
log "  storage_path=${CC_STORAGE_DIR}"
log "  puid:pgid=${PUID}:${PGID}"
log "  cc_data_dir=${CC_DATA_DIR}"
log "  cc_db_path=${CC_DB_PATH}"

exec /usr/local/bin/docker-entrypoint.sh \
    uv run uvicorn cataloguecanvas.main:app --host :: --port 8000
