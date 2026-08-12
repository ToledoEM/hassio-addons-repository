# Obsidian Sync Server NPM

Runs CouchDB as a sync backend for the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin in Obsidian, with [Nginx Proxy Manager](https://nginxproxymanager.com/) bundled in to handle TLS.

Your vault syncs between your own devices through Home Assistant. No Obsidian Sync subscription, and the notes stay on your network.

This version has everything mobile Obsidian needs in one add-on. NPM requests and renews the certificates and proxies HTTPS through to CouchDB. Pick it if you do not already run a reverse proxy.

| Add-on | TLS | Use when |
| :--- | :--- | :--- |
| [Obsidian Sync Server](../obsidian_syncserver_solo/README.md) | none | You already run a reverse proxy |
| [Obsidian Sync Server SSL](../obsidian_syncserver_ssl/README.md) | CouchDB serves HTTPS from your certificates in `/ssl` | You have certificates on the Home Assistant machine |
| Obsidian Sync Server NPM (this one) | Bundled Nginx Proxy Manager | You have no proxy and want certificate handling included |

Note that this add-on binds ports 80, 81 and 443. If you already run the Nginx Proxy Manager + Static Web Server add-on, or anything else on those ports, only one of them can be running at a time. In that case use the plain [Obsidian Sync Server](../obsidian_syncserver_solo/README.md) and add a proxy host to the NPM you already have.

## Ports

| Port | Use |
| :--- | :--- |
| 443 | HTTPS, point Obsidian here |
| 81 | Nginx Proxy Manager admin UI |
| 80 | HTTP, certificate validation and redirect |
| 5984 | CouchDB directly, for desktop or local tools |

## Installation

1. Add this repository to Home Assistant, then install the add-on.
2. Set a password under Configuration. Leaving it blank generates one and prints it in the log on first start.
3. Start the add-on and look for `Ready.` in the log.
4. Open the NPM admin UI on port 81. The default login is `admin@example.com` with password `changeme`, and NPM makes you change both on first login. Do that now rather than later.

## Getting a real certificate

Port 443 answers out of the box, but with a self-signed certificate that mobile Obsidian will reject. To fix that:

1. In the NPM admin UI, go to SSL Certificates, then Add SSL Certificate, then Let's Encrypt.
2. Enter the domain name pointing at your Home Assistant machine, plus your email.
3. If the domain has no public IP, tick Use a DNS Challenge and pick your DNS provider.
4. Once the certificate is issued, go to Hosts, then Proxy Hosts, then Add Proxy Host:
   - Domain Names: your domain
   - Scheme: `http`
   - Forward Hostname / IP: `127.0.0.1`
   - Forward Port: `5984`
   - Websockets Support: on. LiveSync will not sync without it.
   - On the SSL tab, select your certificate and turn on Force SSL.

## Configuration

```yaml
username: admin
password: ""
database: obsidian
log_level: info
```

`username` and `password` are the CouchDB administrator credentials that the LiveSync plugin uses, separate from the NPM admin login. A blank password gets generated on first start and saved to `/config/obsidian-syncserver/admin_password`.

`database` is the CouchDB database holding your vault. The add-on creates it if it does not exist.

`log_level` sets CouchDB log verbosity.

## Connecting Obsidian

Install Self-hosted LiveSync from Obsidian's community plugins. In its settings, pick the manual setup and fill in:

- URI: `https://your-domain`
- Username and password: the CouchDB credentials above
- Database name: `obsidian`, unless you changed it

Hit Test Database Connection to check it, then turn on end-to-end encryption with a passphrase. With that on, the server only ever holds ciphertext.

[DOCS.md](DOCS.md) covers troubleshooting.

## Security

CouchDB requires authentication on every request, and NPM's admin UI has its own login that you have to change the first time you use it. Keep this on your LAN unless you have deliberately set up remote access.
