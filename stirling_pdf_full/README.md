# Stirling-PDF Full — Home Assistant Add-on

[Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) is a locally hosted web application for performing operations on PDF files. This is the **Full** variant, built from the `latest-fat` image. It includes all available external tools and enables every Stirling-PDF feature.

For a lighter install without OCR or Office conversion, see **[Stirling-PDF](../stirling_pdf/)**.

## What this variant adds over Stirling-PDF (basic)

| Feature | Basic | Full |
|---|:---:|:---:|
| Merge, split, compress, rotate, watermark | ✓ | ✓ |
| Sign, annotate, redact, reorder pages | ✓ | ✓ |
| Convert images ↔ PDF | ✓ | ✓ |
| Pipeline / watched-folder automation | ✓ | ✓ |
| REST API | ✓ | ✓ |
| **OCR (Tesseract)** | ✗ | ✓ |
| **PDF → Word / PowerPoint / RTF / XML** | ✗ | ✓ |
| **File → PDF (LibreOffice)** | ✗ | ✓ |
| **Compress / Repair (Ghostscript + qpdf)** | ✗ | ✓ |
| **Compress PDF (ImageMagick)** | ✗ | ✓ |
| **HTML / URL / Markdown → PDF (Weasyprint)** | ✗ | ✓ |
| **PDF → HTML / Markdown (pdftohtml)** | ✗ | ✓ |
| **Image size** | ~600 MB | ~4 GB |

## Installation

1. Go to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Add this repository via the menu (⋮) → **Repositories**.
3. Find **Stirling-PDF Full** and click **Install**.
4. Start the add-on and open the Web UI.

> The first install will take several minutes to download due to the image size.

## Configuration

| Option | Default | Description |
|---|---|---|
| `enable_login` | `false` | Enable Stirling-PDF's built-in authentication. Set to `true` for multi-user environments. |
| `langs` | `en_GB` | Comma-separated Tesseract OCR language codes, e.g. `en_GB,fra,deu`. |
| `log_level` | `info` | Log verbosity: `info`, `debug`, `warn`, or `error`. |

### Enabling login and team features

Stirling-PDF includes optional user authentication, team management, and workspace features. To enable them, set `enable_login` to `true` in the add-on configuration and also add the following to your `settings.yml` at `/config/stirling_pdf_full/configs/settings.yml`:

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
| Configuration & database (`settings.yml`) | `/config/stirling_pdf_full/configs/` |
| Application logs | `/config/stirling_pdf_full/logs/` |
| Tesseract OCR language files | `/share/stirling_pdf_full/tessdata/` |
| Pipeline / watched folders | `/share/stirling_pdf_full/pipeline/` |

### Adding OCR languages

Download `.traineddata` files from the [Tesseract tessdata repository](https://github.com/tesseract-ocr/tessdata) and place them in `/share/stirling_pdf_full/tessdata/`. Then add the language code to the `langs` option and restart.

### Pipeline automation

Place PDF files in `/share/stirling_pdf_full/pipeline/watchedFolders/` to trigger automated processing. Completed outputs appear in `/share/stirling_pdf_full/pipeline/finishedFolders/`.

## Accessing the UI

After the add-on starts, click **Open Web UI** or navigate to `http://homeassistant.local:8080`.

## Architecture Notes

Two-stage Docker build: app and all external tools are copied from `stirlingtools/stirling-pdf:latest-fat` into the Home Assistant Alpine base image (which provides s6-overlay and `bashio`). Only `amd64` and `aarch64` are supported.

## Changelog

### 2.9.2
- Update to Stirling-PDF 2.9.2.

### 2.9.1
- Update to Stirling-PDF 2.9.1.

### 2.9.0
- Update to Stirling-PDF 2.9.0.

### 2.8.0
- Initial release.

## Support

- Stirling-PDF documentation: [docs.stirlingpdf.com](https://docs.stirlingpdf.com)
- Stirling-PDF issues: [github.com/Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
- Add-on issues: open an issue in this repository
