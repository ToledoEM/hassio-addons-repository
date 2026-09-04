# CatalogueCanvas for Home Assistant

<div align="left">
  <img src="logo.png" alt="CatalogueCanvas" width="100" height="100"/>
</div>

A self-hosted manager for your creative files — artwork, generative code, design assets — organised into catalogues and portfolios. This add-on runs CatalogueCanvas on your Home Assistant instance, storing uploads on your own media volume.

This is a rebuild of the [upstream add-on](https://github.com/CatalogueCanvas/cataloguecanvas-homeassistant-addon), published under `ghcr.io/toledoem` so it builds through this repository's pipeline. The application itself is [CatalogueCanvas](https://github.com/CatalogueCanvas/CatalogueCanvas) (AGPL-3.0).

---

## Installation

1. Go to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Open the menu (`···`) → **Repositories**.
3. Add: `https://github.com/ToledoEM/hassio-addons-repository`
4. Find **CatalogueCanvas** in the store and install it.
5. Open the **Configuration** tab and set an **Admin password** — the default is `changeme` and the app refuses admin login until you change it.
6. Start the add-on and open `http://<your-HA-IP>:8081`.

---

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `admin_password` | `changeme` | Admin login password. Change it before starting. |
| `admin_username` | `admin` | Admin account username. |
| `site_title` | `CatalogueCanvas` | Name shown in the UI and on public portfolios. |
| `site_author` | *(empty)* | Author attribution on public portfolios. |
| `cookie_secure` | `false` | Keep off for plain-HTTP LAN access. Turn on only behind HTTPS. |
| `llm_allowed_hosts` | *(empty)* | Comma-separated hostnames the LLM feature may contact (SSRF guard). |
| `max_upload_bytes` | `1073741824` | Largest single asset upload, in bytes (1 GiB). |
| `storage_path` | `/media/cataloguecanvas` | Directory for uploaded assets. Must be under `/media`, `/share`, or `/config`. |
| `puid` | `1000` | User ID owning the storage and config directories. |
| `pgid` | `1000` | Group ID owning the storage and config directories. |

See [DOCS.md](DOCS.md) for storage layout, backup behaviour, and how to point libraries at existing host media.

---

## No sidebar panel

The add-on is reached on port `8081`, not through the Home Assistant sidebar. CatalogueCanvas sends `X-Frame-Options: DENY` and `frame-ancestors 'none'`, and its frontend hard-codes absolute URLs with no base path — both of which Ingress requires. Bookmark `http://<your-HA-IP>:8081` instead.

---

## Backups

The SQLite database and session key live in the add-on's `/config` volume, which Home Assistant backups cover. Uploaded assets live under `storage_path` (default `/media/cataloguecanvas`), which is **not** in Home Assistant backups — back that up separately.

---

## Support

- Add-on issues → [github.com/ToledoEM/hassio-addons-repository](https://github.com/ToledoEM/hassio-addons-repository/issues)
- Upstream add-on → [github.com/CatalogueCanvas/cataloguecanvas-homeassistant-addon](https://github.com/CatalogueCanvas/cataloguecanvas-homeassistant-addon)
- CatalogueCanvas application → [github.com/CatalogueCanvas/CatalogueCanvas](https://github.com/CatalogueCanvas/CatalogueCanvas) · [cataloguecanvas.app](https://cataloguecanvas.app)
