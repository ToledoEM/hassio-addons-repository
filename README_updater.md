# Weekly addon updater

`.github/workflows/weekly_addon_update.yaml` runs every Saturday at 04:00 UTC and checks each addon's upstream image or release for a newer version. Each addon is checked independently. If one is out of date, the workflow bumps its `config.yaml`, adds a `CHANGELOG.md` entry, refreshes the README table, and opens a pull request for that addon alone — `bot/update-<slug>-<version>` against `main`.

Nothing merges automatically. A PR still needs a human to review and merge it, same as any other change to this repo. Opening a PR also means the addon's own `pr-check.yaml` gates (changelog check, addon linter, a dual-arch test build) run against the bump before you look at it.

Merging the PR does not build or publish the image by itself — see [Auto-tag on merge](#auto-tag-on-merge) below for what happens after.

## Dry run by default

Both the cron schedule and manual runs default to dry run: the workflow logs what it *would* change but doesn't touch any files, branches, or PRs. This was intentional for the first few weeks, to catch bad version comparisons before they show up as real PRs. To let it open PRs for real, either pass `dry_run: false` on a manual `workflow_dispatch` run, or flip the default in the workflow file once you trust it.

## How each addon is checked

Every addon directory has an `updater.json` that tells the workflow where to look:

```json
{
  "source": "dockerhub",
  "upstream_repo": "stirlingtools/stirling-pdf",
  "upstream_tag_filter": "fat",
  "upstream_version": "2.13.1",
  "last_update": "2026-08-06"
}
```

`source` picks the fetch strategy:

- **dockerhub** — pulls the tag list from the Docker Hub API, keeps only tags matching `X.Y.Z` (or `X.Y.Z-<upstream_tag_filter>` when a filter is set, for image variants like `-fat` or `-ultra-lite`), and takes the highest by `sort -V`.
- **github** — reads `tag_name` from the repo's latest GitHub release.
- **ghcr** — the addon's image only ever ships as `:latest`, so there's no version tag to read. The workflow compares the image digest instead. When the digest changes, it treats that as a new build and assigns a calendar-style version (today's date) rather than inventing a fake semver.

Setting `"paused": true` in `updater.json` skips the addon entirely, with the reason logged from `"paused_reason"`. `nginx_webserver_proxy` is paused right now — 2.15.x's larger base image trips a memory limit in the build pipeline, tracked in [issue #4](https://github.com/ToledoEM/hassio-addons-repository/issues/4). It'll stay pinned to 2.14.x until that's sorted out.

## Picking the version to write

A newer upstream tag doesn't always mean a version Home Assistant will actually offer as an update. HA's `awesomeversion` library sorts some tags in ways that break the update prompt — `1.2.3-4` reads as older than `1.2.3` under semver pre-release rules, and tags like `nightly-20260801` or `version-bf9e0b4f` don't sort at all.

`.github/scripts/addon_version_resolver.py` handles this. It's a trimmed copy of the version-resolution logic from [alexbelgium/hassio-addons](https://github.com/alexbelgium/hassio-addons)' `addons_updater` add-on, kept to just the parts that decide what to write in `config.yaml`. Given the current version and the upstream tag, it either:

1. Uses the upstream tag as-is, if HA would sort it correctly, or
2. Rewrites it into something sortable (turning `1.2.3-4` into `1.2.3.4`, for instance), or
3. Falls back to a calendar version or an incremented local counter when the upstream tag can't be made sortable at all.

The script ships with 48 known version-history cases as a self-test (`--selftest`), and the workflow runs that check before touching any addon — if the resolver logic is broken, nothing gets bumped.

## Files touched on an update

- `<addon>/config.yaml` — `version:` field
- `<addon>/CHANGELOG.md` — new entry prepended above the previous one, with a link to the upstream release or tag
- `<addon>/updater.json` — `upstream_version` and `last_update` updated so the same upstream release doesn't trigger a second bump next week
- `README.md` — the addon table row, regenerated from all six `config.yaml` files
- A new branch (`bot/update-<slug>-<version>`) and a PR against `main`
- After the PR is merged: a `<slug>@<version>` tag, pushed by `tag_on_merge.yaml`

## Auto-tag on merge

`.github/workflows/tag_on_merge.yaml` runs on every push to `main`. It diffs the merge commit for changed `<addon>/config.yaml` files, and for each one:

1. Skips the addon if its `updater.json` has `"paused": true` — a paused addon's version might still get hand-edited in a PR, and that shouldn't silently trigger a build.
2. Reads the new `version` from `config.yaml`.
3. Pushes a `<slug>@<version>` tag, unless that tag already exists.

That tag is the exact pattern `.github/workflows/build.yaml` listens for, so pushing it triggers the existing build-and-publish pipeline with no extra steps. This applies to any PR that bumps a `config.yaml` version, not just ones opened by the weekly updater — a manual version bump gets the same auto-tag treatment.

## Running it by hand

From the Actions tab, run "Weekly Addon Update" manually and set `dry_run` to `false` to open real PRs, or leave it `true` to just see what it would do in the logs.

Or trigger it from the `gh` CLI:

```bash
# dry run (default, logs only)
gh workflow run weekly_addon_update.yaml

# open PRs for real
gh workflow run weekly_addon_update.yaml -f dry_run=false

# watch the latest run
gh run watch
```

Locally, `.github/scripts/check_addon_update.sh <slug> <true|false>` runs the same check for a single addon — handy for testing a new `updater.json` entry without waiting for Saturday.
