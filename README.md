# HA Addons Playground

[![Build add-on images](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/build.yaml/badge.svg)](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/build.yaml)
[![PR Check](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/pr-check.yaml/badge.svg)](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/pr-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/ToledoEM/hassio-addons-repository)](https://github.com/ToledoEM/hassio-addons-repository/commits/main)
[![Weekly Addon Update](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/weekly_addon_update.yaml/badge.svg)](https://github.com/ToledoEM/hassio-addons-repository/actions/workflows/weekly_addon_update.yaml)

Experimental Home Assistant add-ons by toledoem for toledoem, feel free to try.

*dev versions most of the time, but not always*

## Add this repository to Home Assistant

[![Add to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FToledoEM%2Fhassio-addons-repository)

Or add manually:

1. **Settings** → **Add-ons** → **Add-on Store**
2. Click ⋮ (top right) → **Manage add-on repositories**
3. Paste the URL below and click **Add**

```
https://github.com/ToledoEM/hassio-addons-repository
```

## Add-ons
| Icon | Name | Slug | Version | Description |
| :--- | :--- | :--- | :--- | :--- |
| <img src="bentopdf/icon.png" width="150" height="150" /> | [BentoPDF](bentopdf/README.md) | bentopdf | 2.8.7 | Privacy-first PDF toolkit. 50+ tools, all processing client-side in the browser. Files never leave your device. |
| <img src="manyfold_solo/icon.png" width="150" height="150" /> | [Manyfold](manyfold_solo/README.md) | manyfold_solo | 0.147.1_1 | Manyfold 3D model manager as a Home Assistant add-on, using the manyfold-solo image with configurable library/index paths. |
| <img src="nginx_webserver_proxy/icon.png" width="150" height="150" /> | [Nginx Proxy Manager + Static Web Server](nginx_webserver_proxy/README.md) | nginx_webserver_proxy | 2.14.1-1 | Nginx Proxy Manager with a built-in configurable static file server. Manage reverse proxies via NPM UI on port 81 while serving files from HA storage on port 80. |
| <img src="obsidian_syncserver_npm/icon.png" width="150" height="150" /> | [Obsidian Sync Server NPM](obsidian_syncserver_npm/README.md) | obsidian_syncserver_npm | 3.5.2 | Self-hosted Obsidian LiveSync backend on CouchDB, bundled with Nginx Proxy Manager for TLS and certificate management. |
| <img src="obsidian_syncserver_solo/icon.png" width="150" height="150" /> | [Obsidian Sync Server](obsidian_syncserver_solo/README.md) | obsidian_syncserver_solo | 3.5.2 | Self-hosted Obsidian LiveSync backend on CouchDB. Plain HTTP — put your own reverse proxy in front for TLS. |
| <img src="obsidian_syncserver_ssl/icon.png" width="150" height="150" /> | [Obsidian Sync Server SSL](obsidian_syncserver_ssl/README.md) | obsidian_syncserver_ssl | 3.5.2 | Self-hosted Obsidian LiveSync backend on CouchDB, serving HTTPS with your own certificates from /ssl. Supports mobile Obsidian. |
| <img src="stirling_pdf_fat/icon.png" width="150" height="150" /> | [Stirling-PDF Fat](stirling_pdf_fat/README.md) | stirling_pdf_fat | 2.14.3-fat | Stirling-PDF Fat — all Full features plus additional fonts and pre-bundled jar security. OCR, LibreOffice, Ghostscript, ImageMagick. Larger image (~4 GB). |
| <img src="stirling_pdf_full/icon.png" width="150" height="150" /> | [Stirling-PDF Full](stirling_pdf_full/README.md) | stirling_pdf_full | 2.14.3 | Stirling-PDF Full — all features pre-configured: merge, split, compress, convert, sign, annotate, OCR, and more. |
| <img src="stirling_pdf_ultra_lite/icon.png" width="150" height="150" /> | [Stirling-PDF Ultra-Lite](stirling_pdf_ultra_lite/README.md) | stirling_pdf_ultra_lite | 2.14.3-ultra-lite | Stirling-PDF Ultra-Lite — minimal install with core PDF operations: merge, split, rotate, convert, password protection. Smallest image. |

//Enjoy
