# CatalogueCanvas documentation

[Documentation](https://cataloguecanvas.app)

## Installation

1. Add this repository to Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**, then paste `https://github.com/ToledoEM/hassio-addons-repository`.
2. Install **CatalogueCanvas** from the store.
3. Open the **Configuration** tab and set an **Admin password**. By default the password is **changeme**.
4. Start the add-on and open `http://<your-ha-host>:8081`.

## Why there's no sidebar panel

Ingress (the thing that puts add-ons in the sidebar) works by loading the add-on's UI in an iframe under a path prefix. CatalogueCanvas won't cooperate with either half of that. It sends `X-Frame-Options: DENY` and a `Content-Security-Policy` of `frame-ancestors 'none'`, which block the iframe outright, and its frontend hard-codes absolute URLs with no base path to configure. So the add-on skips Ingress and just serves the app on port 8000.

*You can add `http://<your-ha-host>:8081` in your browser bookmarks.*

## Configuration options

| Option | Required | Default | Description |
| -------- | ---------- | --------- | ------------- |
| `admin_password` | Yes | *(changme)* | Admin login password. |
| `admin_username` | No | `admin` | Admin account username. |
| `site_title` | No | `CatalogueCanvas` | Name shown in the UI and public portfolios. |
| `site_author` | No | *(empty)* | Author attribution on public portfolios. |
| `cookie_secure` | No | `false` | Keep off for plain-HTTP LAN access. Turn on only behind HTTPS. |
| `llm_allowed_hosts` | No | *(empty)* | Comma-separated hostnames the LLM feature may contact (SSRF guard). |
| `max_upload_bytes` | No | `1073741824` | Largest single asset upload, in bytes (default 1 GiB). |
| `storage_path` | No | `/media/cataloguecanvas` | Directory for uploaded assets. Must be under `/media`, `/share`, or `/config`. |
| `puid` | No | `1000` | User ID used to own the storage and config directories. |
| `pgid` | No | `1000` | Group ID used to own the storage and config directories. |

## Data & backups

The SQLite database (`catalogue.db`) and session key (`secret.key`) live in the add-on's `/config` volume, which Home Assistant backups cover. Uploaded assets live under `storage_path` (default `/media/cataloguecanvas`), which is **not** included in Home Assistant backups — point it at a large volume and back it up separately if needed.

## Pointing libraries at host media

A **library** in CatalogueCanvas is just a directory path inside the container. The app checks that the path exists, is a directory, and is writable before it accepts it. To use media that's already on your Home Assistant host, the add-on mounts these host folders into the container:

| Host folder | In-container path | Access |
|-------------|-------------------|--------|
| Media       | `/media`          | read/write |
| Share       | `/share`          | read/write |
| HA config   | `/homeassistant`  | read-only |

So in the UI, point a library at something like `/media/artwork` or `/share/catalogue`. Make the sub-directory on the host first (the Samba or File editor add-on both work) so the path is actually there when the app looks.

> `/homeassistant` is read-only, so you can't put a library there. It's mounted for reference only.

## Networking

The app listens on container port `8000`, published on host port `8081` by default — so you reach it at `http://<your-ha-host>:8081`. You can remap or turn off the host port under the add-on's **Network** settings. This is plain HTTP over your LAN, so leave `cookie_secure` off unless you've put the add-on behind an HTTPS reverse proxy.
