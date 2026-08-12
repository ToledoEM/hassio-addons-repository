# Obsidian Sync Server SSL

Runs CouchDB as a sync backend for the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin in Obsidian, serving HTTPS from certificates you already have.

Your vault syncs between your own devices through Home Assistant. No Obsidian Sync subscription, and the notes stay on your network.

This version serves HTTPS on port 6984 using certificates from `/ssl`, so mobile Obsidian can sync without a separate reverse proxy.

| Add-on | TLS | Use when |
| :--- | :--- | :--- |
| [Obsidian Sync Server](../obsidian_syncserver_solo/README.md) | none | You already run a reverse proxy |
| Obsidian Sync Server SSL (this one) | CouchDB serves HTTPS from your certificates in `/ssl` | You have certificates on the Home Assistant machine |
| [Obsidian Sync Server NPM](../obsidian_syncserver_npm/README.md) | Bundled Nginx Proxy Manager | You have no proxy and want certificate handling included |

## What you need first

A certificate and private key in `/ssl` on the Home Assistant machine. The Let's Encrypt and DuckDNS add-ons both put them there. This add-on only reads them. It never requests or renews anything.

A self-signed certificate usually will not satisfy mobile Obsidian, which wants one it already trusts.

## Installation

1. Add this repository to Home Assistant, then install the add-on.
2. Set a password under Configuration. Leaving it blank generates one and prints it in the log on first start.
3. Check that `certfile` and `keyfile` match the filenames sitting in `/ssl`.
4. Start the add-on. The log should show `TLS enabled on port 6984` and then `Ready.`

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

`username` and `password` are the CouchDB administrator credentials that the LiveSync plugin uses. A blank password gets generated on first start and saved to `/config/obsidian-syncserver/admin_password`.

`database` is the CouchDB database holding your vault. The add-on creates it if it does not exist.

`ssl` turns HTTPS on port 6984 on or off. With it off you get HTTP only, and mobile sync will not work.

`certfile` and `keyfile` are filenames inside `/ssl`.

`log_level` sets CouchDB log verbosity.

## Certificate checks

A broken certificate shows up on the client as an unexplained connection failure, which is miserable to debug. So the add-on checks the certificate before it starts and refuses to run if the file is missing, unreadable, not valid PEM, expired, or does not match the private key. Whichever it is, the log says so.

On a good start it prints the hostnames the certificate covers and the expiry date.

Obsidian has to reach the server by a name the certificate covers. Connecting by IP address when the certificate lists only DNS names will fail.

## Connecting Obsidian

Install Self-hosted LiveSync from Obsidian's community plugins. In its settings, pick the manual setup and fill in:

- URI: `https://<hostname-on-your-certificate>:6984`
- Username and password: whatever you configured above
- Database name: `obsidian`, unless you changed it

Hit Test Database Connection to check it, then turn on end-to-end encryption with a passphrase. With that on, the server only ever holds ciphertext.

[DOCS.md](DOCS.md) covers troubleshooting.

## Security

CouchDB here requires authentication on every request. Keep this on your LAN unless you have deliberately set up remote access.
