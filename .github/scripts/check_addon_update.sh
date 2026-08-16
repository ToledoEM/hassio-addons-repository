#!/usr/bin/env bash
# Check one addon's upstream source for a newer version and, if found,
# patch config.yaml/CHANGELOG.md/updater.json in place. Prints "updated"
# on stdout when a change was made (or would be, in dry-run), nothing
# otherwise. Intended to be called once per addon slug by the weekly
# addon-update workflow.
set -euo pipefail

SLUG="$1"
DRY_RUN="${2:-true}"
TODAY="$(date +%Y-%m-%d)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ADDON_DIR="$SLUG"
UPDATER_JSON="$ADDON_DIR/updater.json"
CONFIG_YAML="$ADDON_DIR/config.yaml"
CHANGELOG="$ADDON_DIR/CHANGELOG.md"

PAUSED=$(jq -r '.paused // false' "$UPDATER_JSON")
if [ "$PAUSED" = "true" ]; then
    REASON=$(jq -r '.paused_reason // "no reason given"' "$UPDATER_JSON")
    echo "$SLUG: updates paused ($REASON)" >&2
    exit 0
fi

SOURCE=$(jq -r '.source' "$UPDATER_JSON")
UPSTREAM_REPO=$(jq -r '.upstream_repo' "$UPDATER_JSON")
UPSTREAM_VERSION=$(jq -r '.upstream_version' "$UPDATER_JSON")
TAG_FILTER=$(jq -r '.upstream_tag_filter // empty' "$UPDATER_JSON")

CURRENT_VERSION=$(yq -r '.version' "$CONFIG_YAML")

fetch_dockerhub_tag() {
    # $2 (variant) selects which build to track: "" for the plain semver
    # tag (e.g. "2.14.2"), or a suffix like "fat"/"ultra-lite" for the
    # matching "<semver>-<variant>" tag.
    local repo="$1" variant="$2"
    local ns image pattern
    ns="${repo%%/*}"
    image="${repo#*/}"
    if [ -n "$variant" ]; then
        pattern="^[0-9]+\.[0-9]+\.[0-9]+-${variant}\$"
    else
        pattern="^[0-9]+\.[0-9]+\.[0-9]+\$"
    fi
    curl -fsSL "https://hub.docker.com/v2/repositories/${ns}/${image}/tags?page_size=100" \
        | jq -r '.results[].name' \
        | grep -xE "$pattern" \
        | sort -V \
        | tail -n 1
}

fetch_github_release() {
    local repo="$1"
    gh api "repos/${repo}/releases/latest" --jq '.tag_name' 2> /dev/null | sed 's/^v//'
}

fetch_ghcr_digest() {
    local repo="$1"
    skopeo inspect "docker://ghcr.io/${repo}:latest" 2> /dev/null | jq -r '.Digest // empty'
}

case "$SOURCE" in
    dockerhub)
        LATEST=$(fetch_dockerhub_tag "$UPSTREAM_REPO" "$TAG_FILTER")
        ;;
    github)
        LATEST=$(fetch_github_release "$UPSTREAM_REPO")
        ;;
    ghcr)
        LATEST=$(fetch_ghcr_digest "$UPSTREAM_REPO")
        ;;
    *)
        echo "::warning::$SLUG: unknown source '$SOURCE', skipping" >&2
        exit 0
        ;;
esac

if [ -z "$LATEST" ]; then
    echo "::warning::$SLUG: could not determine upstream version, skipping" >&2
    exit 0
fi

if [ "$LATEST" = "$UPSTREAM_VERSION" ]; then
    echo "$SLUG: up to date ($CURRENT_VERSION)" >&2
    exit 0
fi

# ghcr digests aren't sortable versions; resolver falls back to a
# calendar version whenever the upstream candidate itself isn't accepted.
RESOLVE_UPSTREAM="$LATEST"
if [ "$SOURCE" = "ghcr" ]; then
    RESOLVE_UPSTREAM="$TODAY"
fi

NEW_VERSION=$(uv run --with awesomeversion python3 "$SCRIPT_DIR/addon_version_resolver.py" \
    --current "$CURRENT_VERSION" --upstream "$RESOLVE_UPSTREAM" --today "$TODAY") || {
    echo "::warning::$SLUG: no Home Assistant compliant version derived from $RESOLVE_UPSTREAM, skipping" >&2
    exit 0
}

if [ -z "$NEW_VERSION" ] || [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
    echo "$SLUG: up to date ($CURRENT_VERSION)" >&2
    exit 0
fi

echo "$SLUG: $CURRENT_VERSION -> $NEW_VERSION (upstream $LATEST)" >&2

if [ "$DRY_RUN" = "true" ]; then
    echo "::notice::[dry-run] $SLUG would update $CURRENT_VERSION -> $NEW_VERSION" >&2
    exit 0
fi

yq -i ".version = \"$NEW_VERSION\"" "$CONFIG_YAML"

case "$SOURCE" in
    github)
        LINK="https://github.com/${UPSTREAM_REPO}/releases/tag/v${LATEST}"
        ;;
    dockerhub)
        LINK="https://hub.docker.com/r/${UPSTREAM_REPO}/tags?name=${LATEST}"
        ;;
    ghcr)
        LINK="https://github.com/${UPSTREAM_REPO}/pkgs/container/$(basename "$UPSTREAM_REPO")"
        ;;
esac

TMP_CHANGELOG=$(mktemp)
{
    head -n 1 "$CHANGELOG"
    echo
    echo "## ${NEW_VERSION}"
    echo
    echo "- Automated upstream update to ${LATEST}."
    echo "- Details: <${LINK}>"
    tail -n +2 "$CHANGELOG"
} > "$TMP_CHANGELOG"
mv "$TMP_CHANGELOG" "$CHANGELOG"

jq --arg version "$LATEST" --arg date "$TODAY" \
    '.upstream_version = $version | .last_update = $date' "$UPDATER_JSON" > "$UPDATER_JSON.tmp"
mv "$UPDATER_JSON.tmp" "$UPDATER_JSON"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    {
        echo "updated=true"
        echo "slug=$SLUG"
        echo "new_version=$NEW_VERSION"
        echo "changelog_link=$LINK"
    } >> "$GITHUB_OUTPUT"
fi

echo "updated"
