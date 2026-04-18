# Nginx Proxy Manager + Static Web Server

A Home Assistant add-on combining [Nginx Proxy Manager](https://nginxproxymanager.com/) with a configurable static file server.

## Features

- Full NPM reverse proxy management via web UI on port 81
- Static file server on port 80 served from a user-configured HA storage path
- Persistent NPM configuration, SSL certificates, and proxy host definitions
- Supports amd64 and aarch64

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `static_site_enabled` | `true` | Enable or disable the static file server |
| `static_site_root` | `/share/www` | Path to serve files from |
| `static_site_prefix` | `/` | URL prefix for the static site on port 80 |
| `log_level` | `info` | Logging verbosity |

## Path Notes

- `/share`, `/media`, `/config` — fully supported; HA maps these volumes automatically.
- `/mnt` — allowed with a warning. HA cannot map `/mnt` via the add-on manifest. If files are not accessible, create a symlink under `/share` or `/media` pointing to your `/mnt` target.
- Dangerous system paths (`/`, `/etc`, `/bin`, `/lib`, `/proc`, `/sys`) are blocked and will prevent startup.

## Default NPM credentials

On first login to the NPM UI (port 81):
- Email: `admin@example.com`
- Password: `changeme`

Change these immediately after first login.
