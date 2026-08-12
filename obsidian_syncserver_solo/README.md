# Obsidian Sync Server

Runs CouchDB as a sync backend for the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin in Obsidian.

Your vault syncs between your own devices through Home Assistant. No Obsidian Sync subscription, and the notes stay on your network.

This add-on speaks plain HTTP. Desktop Obsidian works fine with that. Mobile Obsidian does not, because it insists on a valid TLS certificate. To sync a phone or tablet you need a reverse proxy in front of this add-on, or one of the other two versions:

| Add-on | TLS | Use when |
| :--- | :--- | :--- |
| Obsidian Sync Server (this one) | none | You already run a reverse proxy |
| [Obsidian Sync Server SSL](../obsidian_syncserver_ssl/README.md) | CouchDB serves HTTPS from your certificates in `/ssl` | You have certificates on the Home Assistant machine |
| [Obsidian Sync Server NPM](../obsidian_syncserver_npm/README.md) | Bundled Nginx Proxy Manager | You have no proxy and want certificate handling included |

## Installation

1. Add this repository to Home Assistant, then install the add-on.
2. Set a password under Configuration. Leaving it blank generates one and prints it in the log on first start.
3. Start the add-on and look for `Ready.` in the log.

## Configuration

```yaml
username: admin
password: ""
database: obsidian
log_level: info
```

`username` and `password` are the CouchDB administrator credentials that the LiveSync plugin uses. A blank password gets generated on first start and saved to `/config/obsidian-syncserver/admin_password`.

`database` is the CouchDB database holding your vault. The add-on creates it if it does not exist.

`log_level` sets CouchDB log verbosity.

## Connecting Obsidian

Install Self-hosted LiveSync from Obsidian's community plugins. In its settings, pick the manual setup and fill in:

- URI: `http://<home-assistant-host>:5984`, or your proxy's HTTPS address
- Username and password: whatever you configured above
- Database name: `obsidian`, unless you changed it

Hit Test Database Connection to check it, then turn on end-to-end encryption with a passphrase. With that on, the server only ever holds ciphertext.

[DOCS.md](DOCS.md) covers reverse proxy setup and troubleshooting.

## Security

CouchDB here requires authentication on every request, so nothing is readable anonymously. Still, do not forward port 5984 to the internet. Keep it on your LAN, or put it behind a proxy that terminates TLS and does its own access control.
