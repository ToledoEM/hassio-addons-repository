# Obsidian Sync Server

CouchDB configured as an [Obsidian Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) backend.

## What the add-on configures

CouchDB out of the box will not work as a LiveSync backend. On every start this add-on applies the settings the plugin needs, matching upstream's own provisioning tool:

| Setting | Value | Why |
| :--- | :--- | :--- |
| `chttpd/require_valid_user` | `true` | No anonymous access |
| `chttpd_auth/require_valid_user` | `true` | No anonymous access to the auth endpoints |
| `httpd/WWW-Authenticate` | `Basic realm="couchdb"` | Prompts for credentials |
| `httpd/enable_cors`, `chttpd/enable_cors` | `true` | Obsidian is a browser-style client |
| `cors/credentials` | `true` | Sends the auth header cross-origin |
| `cors/origins` | `app://obsidian.md,capacitor://localhost,http://localhost` | Desktop and mobile app origins |
| `chttpd/max_http_request_size` | `4294967296` | Large vault batches |
| `couchdb/max_document_size` | `50000000` | Large notes and attachments |

These are re-applied on each start, so changing them by hand in Fauxton will not stick.

## Storage

The vault database lives in `/config/obsidian-syncserver/data`, not in the add-on's `/data` directory. That means it survives a reinstall and is included in Home Assistant backups.

The generated admin password, if you did not set one, is at `/config/obsidian-syncserver/admin_password`.

## Reverse proxy setup

Mobile Obsidian rejects plain HTTP, so a phone or tablet needs TLS in front of this add-on. Any proxy works, but it **must**:

- **Pass the `Authorization` header through unchanged.** CouchDB uses HTTP basic auth; a proxy that strips or rewrites this header causes every request to fail with 401.
- **Allow WebSocket upgrades.** LiveSync uses continuous replication; without upgrade support, sync appears to connect and then stalls.
- **Not buffer responses indefinitely**, or long-poll changes feeds will lag.

### Nginx Proxy Manager

Add a **Proxy Host**:

- **Domain Names** — the hostname you will use, e.g. `obsidian.example.com`
- **Scheme** — `http`
- **Forward Hostname / IP** — your Home Assistant machine's address
- **Forward Port** — `5984`
- **Websockets Support** — **on**
- **SSL** tab — request or select a certificate, and enable **Force SSL**

Then point LiveSync at `https://obsidian.example.com`.

### Plain nginx

```nginx
location / {
    proxy_pass http://homeassistant.local:5984;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;

    # Required: CouchDB authenticates every request
    proxy_pass_request_headers on;

    # Required: LiveSync uses continuous replication
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_buffering off;
    proxy_read_timeout 600s;
}
```

## Troubleshooting

**The add-on stops right after starting.** Check the log. A malformed `database` name, or a `/config` directory CouchDB cannot write to, both stop startup with an explicit message.

**LiveSync reports a network or CORS error.** Almost always a proxy problem rather than a CouchDB one. Confirm the server answers directly first:

```bash
curl -u admin:YOURPASSWORD http://homeassistant.local:5984/obsidian
```

If that works but the plugin does not, the proxy is dropping the `Authorization` header or blocking the WebSocket upgrade.

**Mobile will not connect, desktop is fine.** The mobile app requires a certificate it trusts. A self-signed certificate is generally not enough — use a real one, which is what the NPM flavour of this add-on helps with.

**Sync connects then stalls.** WebSocket upgrade is not getting through the proxy.

**Checking the applied configuration:**

```bash
curl -u admin:YOURPASSWORD http://homeassistant.local:5984/_node/_local/_config/cors
```

You should see the Obsidian origins listed.

## Backups

Home Assistant backs up `/config`, which includes the vault database. For a portable copy, use CouchDB's replication or export from Fauxton at `http://<host>:5984/_utils`.
