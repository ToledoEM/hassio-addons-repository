#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -Eeuo pipefail

OPTIONS_JSON="/data/options.json"
DEFAULT_LANGS="en_GB"
DEFAULT_LOG_LEVEL="info"

log() {
  echo "[stirling-pdf-full-addon] $*"
}

die() {
  echo "[stirling-pdf-full-addon] ERROR: $*" >&2
  exit 1
}

read_opt() {
  local key="$1"
  jq -er --arg k "$key" '.[$k]' "$OPTIONS_JSON" 2>/dev/null || true
}

[[ -f "$OPTIONS_JSON" ]] || die "Missing options file at ${OPTIONS_JSON}"

ENABLE_LOGIN="$(read_opt enable_login)"; ENABLE_LOGIN="${ENABLE_LOGIN:-false}"
LANGS="$(read_opt langs)";               LANGS="${LANGS:-$DEFAULT_LANGS}"
LOG_LEVEL="$(read_opt log_level)";       LOG_LEVEL="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

# Persistent directories on HA mapped volumes
CONFIGS_DIR="/config/stirling_pdf_full/configs"
LOGS_DIR="/config/stirling_pdf_full/logs"
TESSDATA_DIR="/share/stirling_pdf_full/tessdata"
PIPELINE_DIR="/share/stirling_pdf_full/pipeline"

mkdir -p "$CONFIGS_DIR" "$LOGS_DIR" "$TESSDATA_DIR" "$PIPELINE_DIR"

# Symlink HA persistent paths → Stirling-PDF expected paths
# fat image uses /configs, /logs, /pipeline at root
for pair in \
  "${CONFIGS_DIR}:/configs" \
  "${LOGS_DIR}:/logs" \
  "${TESSDATA_DIR}:/usr/share/tesseract-ocr/5/tessdata" \
  "${PIPELINE_DIR}:/pipeline"
do
  src="${pair%%:*}"
  dst="${pair##*:}"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -d "$dst" ]]; then
    cp -rn "$dst/." "$src/" 2>/dev/null || true
    rm -rf "$dst"
  fi
  ln -sf "$src" "$dst"
done

export SECURITY_ENABLELOGIN="$ENABLE_LOGIN"
export LANGS
export MODE="BOTH"
export LOGGING_LEVEL="$LOG_LEVEL"

# Cap JVM heap — upstream dynamic calc uses 70% of host RAM which OOMs on HA.
# JAVA_BASE_OPTS is read by /scripts/init-without-ocr.sh before building JAVA_TOOL_OPTIONS.
export JAVA_BASE_OPTS="-XX:+ExitOnOutOfMemoryError -XX:+UseG1GC -XX:+UseStringDeduplication -Dspring.threads.virtual.enabled=true -Xms256m -Xmx512m -XX:MaxMetaspaceSize=256m -XX:MaxRAMPercentage=12"

log "Configuration summary:"
log "  enable_login=${ENABLE_LOGIN}"
log "  langs=${LANGS}"
log "  log_level=${LOG_LEVEL}"
log "  configs=${CONFIGS_DIR}"
log "  tessdata=${TESSDATA_DIR}"
log "  logs=${LOGS_DIR}"
log "  pipeline=${PIPELINE_DIR}"

# Delegate to upstream init script which handles java startup correctly
log "Starting Stirling-PDF Full via /scripts/init.sh"
exec /scripts/init.sh
