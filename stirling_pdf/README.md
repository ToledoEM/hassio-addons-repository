# Stirling-PDF (Basic) — Home Assistant Add-on

> **This is the BASIC variant.** No OCR. No LibreOffice. No Ghostscript. Lightweight and fast to install.
> For the full feature set, use **[Stirling-PDF Full](../stirling_pdf_full/)** instead.

[Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) is a locally hosted web application for performing operations on PDF files.

## Features

- Merge, split, rotate, reorder pages
- Compress, watermark, add/remove passwords
- Sign and annotate PDFs
- Convert images ↔ PDF
- Redact content
- Stateful processing — upload once, use across multiple tools
- Undo & redo — full version history
- Pipeline / watched-folder automation
- REST API for integrations
- Local processing — files never leave your network

## What is NOT included (use Full variant instead)

- OCR (Tesseract)
- PDF ↔ Word / PowerPoint / RTF / XML (LibreOffice)
- Compress / Repair via Ghostscript or qpdf
- HTML / URL / Markdown → PDF (Weasyprint)
- PDF → HTML / Markdown (pdftohtml)

## Installation

1. Go to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Add this repository via the menu (⋮) → **Repositories**.
3. Find **Stirling-PDF** and click **Install**.
4. Start the add-on and open the Web UI.

## Configuration

| Option | Default | Description |
|---|---|---|
| `enable_login` | `false` | Enable Stirling-PDF's built-in authentication. Set to `true` for multi-user environments. |
| `langs` | `en_GB` | Comma-separated Tesseract OCR language codes (for future use with Full variant). |
| `log_level` | `info` | Log verbosity: `info`, `debug`, `warn`, or `error`. |

### Enabling login and team features

Stirling-PDF includes optional user authentication, team management, and workspace features. To enable them, set `enable_login` to `true` in the add-on configuration and also add the following to your `settings.yml` at `/config/stirling_pdf/configs/settings.yml`:

```yaml
security:
  enableLogin: true
```

To additionally unlock user roles, team collaboration, admin controls, and enterprise features, set `DISABLE_ADDITIONAL_FEATURES=false` in the same file:

```yaml
system:
  disableAdditionalFeatures: false
```

See the [Stirling-PDF documentation](https://docs.stirlingpdf.com) for full details on user management.

## Persistent Storage

Data is stored on your Home Assistant host and survives add-on updates and restarts.

| Data | Host path |
|---|---|
| Configuration & database (`settings.yml`) | `/config/stirling_pdf/configs/` |
| Application logs | `/config/stirling_pdf/logs/` |
| Tesseract OCR language files | `/share/stirling_pdf/tessdata/` |
| Pipeline / watched folders | `/share/stirling_pdf/pipeline/` |

### Pipeline automation

Place PDF files in `/share/stirling_pdf/pipeline/watchedFolders/` to trigger automated processing. Completed outputs appear in `/share/stirling_pdf/pipeline/finishedFolders/`.

## Accessing the UI

After the add-on starts, click **Open Web UI** or navigate to `http://homeassistant.local:8080`.

## Architecture Notes

Two-stage Docker build: the Stirling-PDF application is copied from `stirlingtools/stirling-pdf:latest` into the Home Assistant Alpine base image (which provides s6-overlay and `bashio`). Only `amd64` and `aarch64` are supported.

## Changelog

### 2.9.0
- Update to Stirling-PDF 2.9.0.

### 2.8.0
- Initial release.

## Support

- Stirling-PDF documentation: [docs.stirlingpdf.com](https://docs.stirlingpdf.com)
- Stirling-PDF issues: [github.com/Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
- Add-on issues: open an issue in this repository
