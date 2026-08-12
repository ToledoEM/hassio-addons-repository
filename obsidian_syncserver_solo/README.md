# Obsidian Sync Server

Self-hosted [Obsidian Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) backend, running CouchDB as a Home Assistant add-on.

Your vault syncs between your own devices through Home Assistant. No Obsidian Sync subscription, and the notes never leave your network.

This add-on serves **plain HTTP**. Desktop Obsidian is happy with that; **mobile Obsidian is not** — it requires a valid TLS certificate. If you want to sync a phone or tablet, put a reverse proxy in front of this add-on, or use one of the other flavours:

| Add-on | TLS | Use when |
| :--- | :--- | :--- |
| **Obsidian Sync Server** (this one) | none | You already run a reverse proxy |
| [Obsidian Sync Server SSL](../obsidian_syncserver_ssl/README.md) | CouchDB serves HTTPS using your certificates from `/ssl` | You have certificates on the Home Assistant machine |
| [Obsidian Sync Server NPM](../obsidian_syncserver_npm/README.md) | Bundled Nginx Proxy Manager | You have no proxy and want certificate management included |

## Installation

1. Add this repository to Home Assistant, then install **Obsidian Sync Server**.
2. Set a password in the **Configuration** tab (or leave it blank and the add-on generates one, printing it in the log on first start).
3. Start the add-on and check the log for `Ready.`

## Configuration

```yaml
username: admin
password: ""
database: obsidian
log_level: info
```

- **username** / **password** — CouchDB administrator credentials, used by the LiveSync plugin. A blank password is generated on first start and saved to `/config/obsidian-syncserver/admin_password`.
- **database** — the CouchDB database holding your vault. Created automatically.
- **log_level** — CouchDB log verbosity.

## Connecting Obsidian

Install **Self-hosted LiveSync** from Obsidian's community plugins, then in its settings choose the manual setup and enter:

- **URI** — `http://<home-assistant-host>:5984` (or your proxy's HTTPS address)
- **Username** / **Password** — as configured above
- **Database name** — `obsidian`, unless you changed it

Use **Test Database Connection** to confirm, then enable end-to-end encryption with a passphrase. Doing so means the server only ever stores ciphertext.

See [DOCS.md](DOCS.md) for reverse proxy setup and troubleshooting.

## Security

CouchDB is configured to require authentication for every request, so the port is not open to anonymous access. Even so, **do not forward port 5984 to the internet**. Keep it on your LAN, or put it behind a proxy that terminates TLS and enforces its own access control.
