#!/usr/bin/env bash
set -euo pipefail

OWNER="${OWNER:-ToledoEM}"
REPO="${REPO:-hassio-addons-repository}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADDONS_TXT="$REPO_ROOT/addons.txt"
OUT="${1:-$REPO_ROOT/.github/stats/downloads.json}"
GENERATED="${GENERATED:-$(date -u +%Y-%m-%d)}"

mkdir -p "$(dirname "$OUT")"

scrape_all() {
  gh api "users/$OWNER/packages?package_type=container&per_page=100" \
    --jq ".[] | select(.repository.name==\"$REPO\") | .name" |
  while read -r pkg; do
    case "$pkg" in
      *-amd64)   slug="${pkg%-amd64}";   arch=amd64 ;;
      *-aarch64) slug="${pkg%-aarch64}"; arch=aarch64 ;;
      *) continue ;;
    esac
    grep -qx "$slug" "$ADDONS_TXT" || continue

    created=$(gh api "users/$OWNER/packages/container/$pkg" --jq '.created_at')

    page=$(curl -sL "https://github.com/$OWNER/$REPO/pkgs/container/$pkg")

    count=$(rg -U -o 'Total downloads</span>\s*<h3 title="([0-9,]+)"' -r '$1' <<<"$page" |
      tr -d ',') || true

    if [ -z "$count" ]; then
      echo "::warning::$pkg: could not read download count, skipping" >&2
      continue
    fi

    jq -nc --arg s "$slug" --arg a "$arch" --arg c "$created" --argjson n "$count" \
      '{slug:$s, arch:$a, downloads:$n, created:$c}'
  done
}

rows="$(scrape_all | jq -sc 'sort_by(.slug, .arch)')"

if [ "$(jq 'length' <<<"$rows")" -eq 0 ]; then
  echo "no download counts collected, refusing to write an empty file" >&2
  exit 1
fi

jq -n --arg g "$GENERATED" --argjson rows "$rows" \
  '{generated:$g, rows:$rows}' > "$OUT"

echo "wrote $(jq '.rows | length' "$OUT") rows to $OUT"
