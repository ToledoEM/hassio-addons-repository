# Stirling-PDF Ultra-Lite — Home Assistant Add-on

**Current version: 2.11.0**

The lightest Stirling-PDF tier. No OCR, no LibreOffice, no Ghostscript. Installs fast and runs on modest hardware.

For OCR and Office conversion, use **[Stirling-PDF Full](../stirling_pdf_full/)**.
For all features plus extra fonts and bundled security, use **[Stirling-PDF Fat](../stirling_pdf_fat/)**.

[Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) is a self-hosted web app for PDF operations.

## Features

- Merge, split, rotate, reorder pages
- Compress, watermark, add/remove passwords
- Sign and annotate PDFs
- Convert images to and from PDF
- Redact content
- Upload once, use across multiple tools
- Full undo and redo history
- Pipeline and watched-folder automation
- REST API
- Local processing — files never leave your network

## Not included

These require the Full or Fat variant:

- OCR (Tesseract)
- PDF to and from Word, PowerPoint, RTF, XML (LibreOffice)
- Compress and repair via Ghostscript or qpdf
- HTML, URL, Markdown to PDF (Weasyprint)
- PDF to HTML or Markdown (pdftohtml)

## Requirements

| | Minimum | Recommended |
|---|---|---|
| **RAM** | 2 GB | 4 GB |
| **Storage** | 700 MB | — |
| **Arch** | amd64, aarch64 | — |

The add-on caps the container at 1 GB and sizes the JVM heap to 40% of available RAM. Less than 1 GB free causes startup failures.

## Installation

1. Go to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Open the menu (⋮) and select **Repositories**, then add this repository URL.
3. Find **Stirling-PDF Ultra-Lite** and click **Install**.
4. Start the add-on and open the Web UI.

## Configuration

| Option | Default | Description |
|---|---|---|
| `enable_login` | `false` | Turn on built-in authentication for multi-user setups. |
| `langs` | `en_GB` | Comma-separated Tesseract language codes (reserved for future use). |
| `log_level` | `info` | Verbosity: `info`, `debug`, `warn`, or `error`. |

### Login and team features

Set `enable_login` to `true` in the add-on configuration, then add this to `/config/stirling_pdf_ultra_lite/configs/settings.yml`:

```yaml
security:
  enableLogin: true
```

To unlock user roles, team collaboration, and admin controls, add:

```yaml
system:
  disableAdditionalFeatures: false
```

See the [Stirling-PDF documentation](https://docs.stirlingpdf.com) for user management details.

## Persistent Storage

All data survives add-on updates and restarts.

| Data | Host path |
|---|---|
| Configuration and settings | `/config/stirling_pdf_ultra_lite/configs/` |
| Application logs | `/config/stirling_pdf_ultra_lite/logs/` |
| Tesseract language files | `/share/stirling_pdf_ultra_lite/tessdata/` |
| Pipeline and watched folders | `/share/stirling_pdf_ultra_lite/pipeline/` |

### Pipeline automation

Drop PDF files into `/share/stirling_pdf_ultra_lite/pipeline/watchedFolders/`. Processed outputs land in `/share/stirling_pdf_ultra_lite/pipeline/finishedFolders/`.

## Accessing the UI

After startup, click **Open Web UI** or go to `http://homeassistant.local:8080`.

## Architecture Notes

Single-stage build on top of `stirlingtools/stirling-pdf:latest-ultra-lite`. s6-overlay and bashio are installed on the upstream image. Only `amd64` and `aarch64` are supported.

## Changelog

### 2.11.0
- Update to Stirling-PDF 2.11.0.

### 2.10.0
- Update to Stirling-PDF 2.10.0.

### 2.9.2
- Update to Stirling-PDF 2.9.2.

### 2.9.1
- Update to Stirling-PDF 2.9.1.

### 2.9.0
- Update to Stirling-PDF 2.9.0.

### 2.8.0
- Initial release.

## Support

- Stirling-PDF docs: [docs.stirlingpdf.com](https://docs.stirlingpdf.com)
- Stirling-PDF issues: [github.com/Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
- Add-on issues: open an issue in this repository
