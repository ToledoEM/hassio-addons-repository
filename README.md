# Manyfold Home Assistant Add-on

![Manyfold Home Assistant Add-on logo](manyfold_solo/logo.png)

This repository provides a Home Assistant OS add-on for Manyfold with persistent storage and configurable host-backed media paths.

Documentation: [manyfold.app/get-started](https://manyfold.app/get-started/)

**Now in the Custom alexbelgium/hassio-addons Add-on Store! 💪**   
 Search for "Manyfold" and install directly from there and instructions how to add it to your Home Assistant instance. [link](https://github.com/alexbelgium/hassio-addons)


## Features

- Runs Manyfold on port `3214`.
- Persists app data, database, cache, and settings under `/config` (`addon_config`).
- Uses configurable library and thumbnails paths on Home Assistant host storage.
- Refuses startup if configured paths resolve outside `/share`, `/media`, or `/config`.
- No external PostgreSQL or Redis required.
- Supports `amd64` and `aarch64`.

## Repository layout

- `repository.yaml`: Home Assistant add-on repository manifest.
- `manyfold_solo/`: Add-on package consumed by Home Assistant OS.

## Default paths

- Library path: `/share/manyfold/models`
- Thumbnails path: `/config/thumbnails`

## Installation

1. In Home Assistant OS Add-on Store, open menu (`...`) -> `Repositories`.
2. Add the Git repository URL: `https://github.com/ToledoEM/hassio-addons`.
3. Refresh Add-on Store and install **Manyfold**.
4. Configure options (defaults are safe for first run):
   - `library_path`: `/share/manyfold/models`
   - `secret_key_base`: leave blank to auto-generate
5. Start the add-on.
6. Open `http://<HA_IP>:3214`.

Local development alternative on the HA host:

1. Copy `manyfold_solo/` to `/addons/manyfold_solo`.
2. In Add-on Store menu (`...`), click `Check for updates`.
3. Install and run **Manyfold** from local add-ons.

## Library/index workflow

1. Drop STL/3MF/etc into `/share/manyfold/models` on the host.
2. In Manyfold UI, configure a library that points to the same container path.
3. Thumbnails and indexing artifacts persist in `/config/thumbnails`.

## Options

- `secret_key_base`: App secret used by Rails to sign/encrypt sessions and tokens. See [Secret Key Base](#secret-key-base) below.
- `puid` / `pgid`: Ownership applied to mapped directories.
- `multiuser`: Toggle Manyfold multiuser mode.
- `library_path`: Scanned/indexed path.
- `thumbnails_path`: Persistent thumbnails/index artifacts (must be under `/config`).
- `log_level`: `info`, `debug`, `warn`, `error`.

## Validation behavior

- Startup fails if `library_path` or `thumbnails_path` resolve outside mapped storage roots.
- `thumbnails_path` must resolve under `/config` to guarantee persistence.

## Notes

- This baseline avoids Home Assistant ingress and keeps direct port access.
- If `puid`/`pgid` change, restart the add-on to re-apply ownership to mapped directories.

## Secret Key Base

`secret_key_base` is a required Rails secret used to sign and encrypt user sessions and tokens. Changing it will invalidate all active sessions and log everyone out.

**How it works:**

| Scenario | Behaviour |
|----------|-----------|
| **New install**, option left blank | A random secret is auto-generated and saved to `/config/secret_key_base` |
| **Addon update**, option still blank | The previously saved `/config/secret_key_base` is reused — no data loss |
| **Option manually set** | The value from the addon options is used directly |
| **Option was set, then cleared on update** | A new secret is generated — **sessions will be invalidated** |

**Recommendation:** Leave `secret_key_base` blank on first install and never change it afterwards. The auto-generated value persists across updates in `/config/secret_key_base`, which is part of the addon config storage and is included in Home Assistant backups.

If you ever need to migrate to a new HA instance, copy `/config/secret_key_base` alongside your database to avoid losing sessions.

## Versioning

The add-on version in `config.yaml` (`version`) must match an existing tag of the upstream Docker image
[`ghcr.io/manyfold3d/manyfold-solo`](https://github.com/manyfold3d/manyfold/pkgs/container/manyfold-solo),
since Home Assistant uses it directly as the image tag when pulling.
This means the add-on version number reflects the **Manyfold app version**, not an independent add-on release version.
When a new Manyfold release is published upstream, update `version` in `config.yaml` to match the new tag (e.g. `0.99.1` → `1.0.0`).
