# Changelog


## 2.14.1-1

- Persist Let's Encrypt certificates across restarts by symlinking /etc/letsencrypt to /data/letsencrypt (#2828) — thanks to @crazyrokr for reporting and suggesting the fix


## 2.14.1

- Fix startup failure on aarch64/HAos: "/usr/bin/env: 'bash': Permission denied" (#2777)
- Add custom AppArmor profile allowing the s6-overlay boot chain and bash/env exec


## 2.14.0

- Initial release wrapping jc21/nginx-proxy-manager:latest
- NPM Admin UI on port 81; HTTP on port 80; HTTPS on port 443
- Configurable static file server via NPM's default_host nginx config
- Supports /share, /media, /config paths; warns for /mnt; blocks dangerous system paths
- NPM state persisted via Docker volume (managed by HA Supervisor)
- Supports amd64 and aarch64
