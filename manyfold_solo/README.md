# Manyfold Home Assistant Add-on

This add-on wraps `ghcr.io/manyfold3d/manyfold-solo` for Home Assistant OS with persistent storage and configurable host-backed media paths.

Documentation: [manyfold.app/get-started](https://manyfold.app/get-started/)

## Features

- Runs Manyfold on port `3214`.
- Persists app data, database, cache, and settings under `/config` (`addon_config`).
- Uses a configurable library path on Home Assistant host storage.
- Refuses startup if configured paths resolve outside `/share`, `/media`, or `/config`.
- No external PostgreSQL or Redis required.
- Supports `amd64` and `aarch64`.
- Includes a baseline AppArmor profile.

## Default paths

- Library path: `/share/manyfold/models`
- Thumbnails path: `/config/thumbnails`

## Installation

1. Add my add-ons repository to your home assistant instance (in supervisor addons store at top right, or click button below if you have configured my HA)
   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Falexbelgium%2Fhassio-addons)
2. Refresh Add-on Store and install **Manyfold**.
3. Configure options (defaults are safe for first run):
   - `library_path`: `/share/manyfold/models`
   - `secret_key_base`: leave blank to auto-generate
   - `puid` / `pgid`: set to a non-root UID/GID (see "Fix root warning (PUID/PGID)" below)
   - optionally tune worker/thread and upload limits in "Small server tuning" below
4. Start the add-on.
5. Open `http://<HA_IP>:3214`.

Before first start, ensure your library folder exists on the Home Assistant host (for example via the Terminal & SSH add-on):

```bash
mkdir -p /share/manyfold/models
```

Local development alternative on the HA host:

1. Copy `manyfold_solo/` to `/addons/manyfold_solo`.
2. In Add-on Store menu (`...`), click `Check for updates`.
3. Install and run **Manyfold** from local add-ons.

## Library/index workflow

1. Drop STL/3MF/etc into `/share/manyfold/models` on the host.
2. In Manyfold UI, configure a library that points to the same container path.
3. Thumbnails and indexing artifacts persist in `/config/thumbnails`.

## Options

- `secret_key_base`: App secret. Auto-generated and persisted at `/config/secret_key_base` when empty.
- `public_hostname`: Host used in generated absolute links (see "Open in slicer links" below). Leave blank to auto-detect the Home Assistant host; set a hostname or LAN IP when needed.
- `puid` / `pgid`: Ownership applied to writable mapped directories (`/config` paths).
- `multiuser`: Toggle Manyfold multiuser mode.
- `library_path`: Scanned/indexed path.
- `thumbnails_path`: Persistent thumbnails/index artifacts (must be under `/config`).
- `log_level`: `info`, `debug`, `warn`, `error`.
- `web_concurrency`: Puma worker process count.
- `rails_max_threads`: Max threads per Puma worker.
- `default_worker_concurrency`: Sidekiq default queue concurrency.
- `performance_worker_concurrency`: Sidekiq performance queue concurrency.
- `max_file_upload_size`: Max uploaded archive size in bytes.
- `max_file_extract_size`: Max extracted archive size in bytes.

## Small server tuning

For low-memory HAOS hosts, start with:

```yaml
web_concurrency: 1
rails_max_threads: 5
default_worker_concurrency: 2
performance_worker_concurrency: 1
max_file_upload_size: 268435456
max_file_extract_size: 536870912
```

Then restart the add-on and increase gradually only if needed.

### Raspberry Pi (single-user) example

For a Raspberry Pi 4 or Pi 5 running a single-user Manyfold instance with modest library sizes:

```yaml
puid: 1000
pgid: 1000
multiuser: false
library_path: /share/manyfold/models
thumbnails_path: /config/thumbnails
log_level: info
web_concurrency: 1
rails_max_threads: 4
default_worker_concurrency: 1
performance_worker_concurrency: 1
max_file_upload_size: 134217728
max_file_extract_size: 268435456
```

**Rationale:**
- `web_concurrency: 1` — Single Puma worker (one process) saves RAM on Pi.
- `rails_max_threads: 4` — Four threads per worker is sufficient for single-user browsing.
- `default_worker_concurrency: 1` — Serial background job processing (indexing, thumbnail generation).
- `performance_worker_concurrency: 1` — Single performance worker to avoid CPU thrashing during STL processing.
- `multiuser: false` — Disable authentication/multiuser features for personal use.
- `max_file_upload_size: 128 MB` — Reasonable limit for Pi storage and network.
- `max_file_extract_size: 256 MB` — Extracted archives stay manageable.

## Fix root warning (PUID/PGID)

If Manyfold shows:

`Manyfold is running as root, which is a security risk.`

set `puid` and `pgid` in the add-on Configuration tab to a non-root UID/GID.

Example:

```yaml
puid: 1000
pgid: 1000
```

How to find the correct values in Home Assistant:

1. Open the **Terminal & SSH** add-on (or SSH into the HA host).
2. If you know the target Linux user name, run:

```bash
id <username>
```

Use the `uid=` value for `puid` and `gid=` value for `pgid`.

If you do not have a specific username, use the owner of the Manyfold folders:

```bash
stat -c '%u %g' /share/manyfold/models
```

Set `puid`/`pgid` to those numbers.

After changing values:

1. Save add-on Configuration.
2. Restart the Manyfold add-on.
3. Check logs for `puid:pgid=<uid>:<gid>` and confirm the warning is gone.

## Open in slicer links (`public_hostname`)

Manyfold builds absolute URLs — including the "Open in OrcaSlicer / PrusaSlicer / Bambu Studio / Cura / ..." download links — from a single configured host. When that host is unset, Manyfold defaults to `localhost`, so every generated link looks like `http://localhost:3214/...`.

That link only works on the machine running the add-on. When you click it from a phone, laptop, or any other computer, `localhost` points back at *that* device, the download fails, and the slicer opens with nothing loaded.

To fix this, the add-on sets Manyfold's `PUBLIC_HOSTNAME` (and `PUBLIC_PORT=3214`) for you:

- Leave `public_hostname` **blank** and the add-on asks the Supervisor for the Home Assistant host name and uses that.
- If auto-detection does not resolve from your other devices (for example when mDNS/`.local` names are blocked), set `public_hostname` manually to a name or LAN IP those devices can reach, e.g. `homeassistant.local` or `192.168.1.50`. A DHCP reservation keeps an IP stable.

After changing it, restart the add-on and check the log for `public_hostname=<value>`, then regenerate a slicer link. Existing links are generated at click time, so no re-export is needed.

## Update procedure

This add-on uses the pre-built `manyfold-solo` image from GitHub Container Registry (`ghcr.io/manyfold3d/manyfold-solo`), so updating is straightforward.

When a new version is released:

1. In HA, go to **Settings → Add-ons → Add-on Store**.
2. Click the **⋮ menu** (top right) → **Check for updates** (or **Reload**).
3. Open the **Manyfold** add-on page.
4. Click **Update** to pull the latest image and restart.

## Validation behavior

- Startup fails if `library_path` or `thumbnails_path` resolve outside mapped storage roots.
- `thumbnails_path` must resolve under `/config` to guarantee persistence.
- Startup fails if `library_path` is not readable.

## Notes

- This baseline avoids Home Assistant ingress and keeps direct port access.
- If `puid`/`pgid` change, restart the add-on to re-apply ownership to mapped directories.
