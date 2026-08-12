# Obsidian Sync Server SSL

Self-hosted [Obsidian Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) backend, running CouchDB as a Home Assistant add-on, serving HTTPS with your own certificates.

Your vault syncs between your own devices through Home Assistant. No Obsidian Sync subscription, and the notes never leave your network.

This flavour serves **HTTPS on port 6984** using certificates you already have in `/ssl`, so **mobile Obsidian can sync** without a separate reverse proxy.

| Add-on | TLS | Use when |
| :--- | :--- | :--- |
| [Obsidian Sync Server](../obsidian_syncserver_solo/README.md) | none | You already run a reverse proxy |
| **Obsidian Sync Server SSL** (this one) | CouchDB serves HTTPS using your certificates from `/ssl` | You have certificates on the Home Assistant machine |
| [Obsidian Sync Server NPM](../obsidian_syncserver_npm/README.md) | Bundled Nginx Proxy Manager | You have no proxy and want certificate management included |

## Requirements

You need a certificate and private key in `/ssl` on the Home Assistant machine. These are normally put there by the **Let's Encrypt** or **DuckDNS** add-on. This add-on reads them; it never requests or renews certificates itself.

> A self-signed certificate is usually **not** enough for mobile Obsidian — it wants one it already trusts.

## Installation

1. Add this repository to Home Assistant, then install **Obsidian Sync Server SSL**.
2. Set a password in the **Configuration** tab (or leave it blank and the add-on generates one, printing it in the log on first start).
3. Confirm `certfile` and `keyfile` match the filenames in `/ssl`.
4. Start the add-on and check the log for `TLS enabled on port 6984` followed by `Ready.`

## Configuration

```yaml
username: admin
password: ""
database: obsidian
ssl: true
certfile: fullchain.pem
keyfile: privkey.pem
log_level: info
```

- **username** / **password** — CouchDB administrator credentials, used by the LiveSync plugin. A blank password is generated on first start and saved to `/config/obsidian-syncserver/admin_password`.
- **database** — the CouchDB database holding your vault. Created automatically.
- **ssl** — serve HTTPS on 6984. Turn off to run HTTP only, in which case mobile sync will not work.
- **certfile** / **keyfile** — filenames inside `/ssl`.
- **log_level** — CouchDB log verbosity.

## Certificate checks

The add-on validates the certificate before starting, because a bad certificate shows up on the client as an unexplained "cannot connect". It refuses to start, naming the cause, when the certificate is missing, unreadable, not valid PEM, **expired**, or does not match the private key. The covered hostnames and the expiry date are printed to the log on every successful start.

Obsidian must reach the server using a hostname the certificate covers. Connecting by IP address when the certificate lists only a DNS name will be rejected by the client.

## Connecting Obsidian

Install **Self-hosted LiveSync** from Obsidian's community plugins, then in its settings choose the manual setup and enter:

- **URI** — `https://<hostname-on-your-certificate>:6984`
- **Username** / **Password** — as configured above
- **Database name** — `obsidian`, unless you changed it

Use **Test Database Connection** to confirm, then enable end-to-end encryption with a passphrase. Doing so means the server only ever stores ciphertext.

See [DOCS.md](DOCS.md) for troubleshooting.

## Security

CouchDB is configured to require authentication for every request. Even so, keep this on your LAN — do not forward these ports to the internet.
