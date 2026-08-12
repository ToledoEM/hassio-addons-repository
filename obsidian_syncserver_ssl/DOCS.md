# Obsidian Sync Server SSL

CouchDB configured as an [Obsidian Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) backend, serving HTTPS directly from certificates in `/ssl`.

## Ports

| Port | Protocol | Use |
| :--- | :--- | :--- |
| 5984 | HTTP | Desktop Obsidian, Fauxton, local tools |
| 6984 | HTTPS | Mobile Obsidian, anything needing TLS |

Both are served at once. HTTPS appears only when `ssl` is on and the certificate passes validation.

## Certificates

Certificates come from `/ssl`, which is mapped read-only. They are normally written there by the **Let's Encrypt** or **DuckDNS** add-on.

**This add-on never renews certificates.** It only reads them. When the certificate expires, the add-on refuses to start until the file is renewed by whatever put it there. That is deliberate: silently serving an expired certificate produces a sync failure on the phone with no explanation, which is far harder to diagnose than a stopped add-on with a clear message.

### What is checked before startup

| Check | Failure message names |
| :--- | :--- |
| File present and readable | The exact path that was tried |
| Valid PEM certificate | The file that would not parse |
| Valid PEM private key | The file that would not parse |
| Not expired | The expiry date |
| Certificate matches key | Both filenames |

On success, the log shows the covered hostnames and the expiry date:

```
Certificate covers: obsidian.example.com
Obsidian must reach this server by one of those names, or it will reject the certificate.
TLS enabled on port 6984 (certificate valid until Nov  3 12:00:00 2026 GMT)
```

The hostname list is a warning aid, not a hard check — reaching the server by an alternate name is legitimate, so the add-on still starts.

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

## Troubleshooting

**The add-on will not start and the log mentions the certificate.** The message names the specific problem — missing file, unparseable PEM, expired, or a certificate/key mismatch. Fix that file in `/ssl`, or set `ssl` to `false` to run HTTP only while you sort it out.

**Certificate expired.** Renew it with whatever add-on issues it (Let's Encrypt or DuckDNS), then restart this add-on. Check that the renewal is actually scheduled — a certificate that expired months ago usually means nothing is renewing it.

**Desktop syncs, mobile does not.** Almost always the certificate. Confirm the phone reaches the server by a hostname the certificate covers, not by IP address, and that the issuing authority is one the phone trusts. Self-signed certificates are typically rejected.

**Verify TLS is actually being served:**

```bash
openssl s_client -connect yourhost:6984 </dev/null | openssl x509 -noout -subject -dates
```

**Check the applied configuration:**

```bash
curl -u admin:YOURPASSWORD https://yourhost:6984/_node/_local/_config/cors
```

You should see the Obsidian origins listed.

**LiveSync reports a CORS or network error over HTTPS.** Confirm the plain HTTP port works first:

```bash
curl -u admin:YOURPASSWORD http://homeassistant.local:5984/obsidian
```

If HTTP works and HTTPS does not, the problem is the certificate rather than CouchDB.

## Backups

Home Assistant backs up `/config`, which includes the vault database. For a portable copy, use CouchDB's replication or export from Fauxton at `https://<host>:6984/_utils`.
