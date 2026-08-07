# Weekly addon updater

`.github/workflows/weekly_addon_update.yaml` and `.github/workflows/tag_on_merge.yaml` together check each addon's upstream image or release weekly, and take a version bump all the way from "newer version exists" to "image built and published" — with a human review step in between.

## Step by step

- **Saturday 04:00 UTC** (or manual trigger), `weekly_addon_update.yaml` runs
- For each of the 6 addons, independently:
  - Reads `<addon>/updater.json` to find its upstream source (Docker Hub, GitHub Releases, or ghcr digest)
  - Fetches the latest upstream version
  - Runs it through `addon_version_resolver.py` to get a Home Assistant–compliant version string
  - If that's newer than the addon's current `config.yaml` version:
    - Bumps `config.yaml`, adds a `CHANGELOG.md` entry, updates `updater.json`
    - Pushes a branch `bot/update-<slug>-<version>`
    - Opens a PR against `main` — scoped to that addon's 3 files only, nothing else
  - If nothing changed, or the run is a dry run, it just logs and stops there
- The PR triggers `pr-check.yaml` automatically — changelog check, addon linter, dual-arch test build — same gates any human PR goes through
- **A human reviews and merges the PR.** Nothing merges on its own.
- Merging into `main` triggers `tag_on_merge.yaml`:
  - Detects which addon's `config.yaml` changed in that merge
  - Skips it if `updater.json` has `"paused": true`
  - Pushes a `<slug>@<version>` tag (unless it already exists)
  - That tag matches `build.yaml`'s trigger pattern, so the image build/publish pipeline fires automatically
  - Separately, regenerates the README add-on table. If it changed, opens (or updates) a small PR — `bot/sync-readme` — since `main` is protected and nothing can push to it directly, not even this automation. This still happens after merge, not inside the addon's own PR, so two bot PRs updating different addons in the same week never conflict with each other over the README

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

In the PR (bot branch, scoped to one addon):

- `<addon>/config.yaml` — `version:` field
- `<addon>/CHANGELOG.md` — new entry prepended above the previous one, with a link to the upstream release or tag
- `<addon>/updater.json` — `upstream_version` and `last_update` updated so the same upstream release doesn't trigger a second bump next week

After the PR is merged, handled by `tag_on_merge.yaml`:

- A `<slug>@<version>` tag, pushed directly (tags aren't affected by branch protection)
- `README.md` — the addon table row, regenerated from all six `config.yaml` files. If it changed, it goes into its own small PR (`bot/sync-readme`), not a direct commit — see below.

Bot PRs never touch `README.md` directly — that's deliberate. Two PRs updating different addons in the same week both used to diff the same README table lines, so whichever merged first left the other in a merge-conflict state. Moving the regeneration to a post-merge step removes that entirely, since there's only ever one README change in flight at a time.

## main is protected

`main` has branch protection: a pull request is required to merge, and this applies to everyone, including admins — there's no bypass. Nothing, human or bot, can push a commit directly to `main`. This is why `tag_on_merge.yaml`'s README sync opens a PR instead of committing straight to `main` (an earlier version of this workflow tried to push directly and started failing with `GH013: Repository rule violations` once the ruleset went live).

Tags are unaffected by this — `refs/tags/*` isn't a branch ref, so `tag_on_merge.yaml` can still push tags directly without hitting the ruleset.

## Auto-tag on merge

`.github/workflows/tag_on_merge.yaml` runs on every push to `main` (i.e. every time a PR merges). It diffs the merge commit for changed `<addon>/config.yaml` files, and for each one:

1. Skips the addon if its `updater.json` has `"paused": true` — a paused addon's version might still get hand-edited in a PR, and that shouldn't silently trigger a build.
2. Reads the new `version` from `config.yaml`.
3. Pushes a `<slug>@<version>` tag, unless that tag already exists.

That tag is the exact pattern `.github/workflows/build.yaml` listens for, so pushing it triggers the existing build-and-publish pipeline with no extra steps. This applies to any PR that bumps a `config.yaml` version, not just ones opened by the weekly updater — a manual version bump gets the same auto-tag treatment.

Tagging and pushing use a `TAG_PUSH_TOKEN` secret (a fine-grained PAT with contents write access) instead of the default `GITHUB_TOKEN` — GitHub doesn't let the default token's pushes trigger other workflows, which would silently stop the tag from ever kicking off `build.yaml`.

The same job then regenerates `README.md`. If it changed, it opens (or, if one's already open, updates) a PR on branch `bot/sync-readme` — same PR-required rule as everything else, since `main` won't accept a direct push. See [main is protected](#main-is-protected) above.

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
