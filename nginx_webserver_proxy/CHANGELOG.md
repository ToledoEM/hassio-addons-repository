# Changelog

## 1.0.0

- Initial release wrapping jc21/nginx-proxy-manager (NPM 2.12.3)
- NPM Admin UI on port 81; HTTP on port 80; HTTPS on port 443
- Configurable static file server via NPM's custom nginx include
- Supports /share, /media, /config paths; warns for /mnt; blocks dangerous system paths
- NPM state persisted to addon_config volume via /data symlink
- Supports amd64 and aarch64
