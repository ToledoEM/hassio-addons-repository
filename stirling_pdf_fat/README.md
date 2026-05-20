# Stirling-PDF Fat — Home Assistant Add-on

**Current version: 2.11.0**

The largest Stirling-PDF tier. Includes everything in Full, plus extra fonts and pre-bundled security jars. Choose it when you need broad font coverage or air-gapped operation.

For a smaller install with OCR and Office conversion, use **[Stirling-PDF Full](../stirling_pdf_full/)**.
For the lightest install, use **[Stirling-PDF Ultra-Lite](../stirling_pdf_ultra_lite/)**.

[Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) is a self-hosted web app for PDF operations.

## What Fat adds over Full

| Feature | Full | Fat |
|---|:---:|:---:|
| Merge, split, compress, rotate, watermark | ✓ | ✓ |
| Sign, annotate, redact, reorder pages | ✓ | ✓ |
| Convert images to and from PDF | ✓ | ✓ |
| Pipeline and watched-folder automation | ✓ | ✓ |
| REST API | ✓ | ✓ |
| OCR (Tesseract) | ✓ | ✓ |
| PDF to Word, PowerPoint, RTF, XML | ✓ | ✓ |
| Files to PDF (LibreOffice) | ✓ | ✓ |
| Compress and repair (Ghostscript + qpdf) | ✓ | ✓ |
| Compress PDF (ImageMagick) | ✓ | ✓ |
| HTML, URL, Markdown to PDF (Weasyprint) | ✓ | ✓ |
| PDF to HTML or Markdown (pdftohtml) | ✓ | ✓ |
| **Extra fonts** | ✗ | ✓ |
| **Pre-bundled security jars** | ✗ | ✓ |
| **Image size** | ~4 GB | ~5 GB |

## Requirements

| | Minimum | Recommended |
|---|---|---|
| **RAM** | 4 GB | 8 GB+ |
| **Storage** | 5 GB | — |
| **Arch** | amd64, aarch64 | — |

The add-on caps the container at 4 GB and sizes the JVM heap to 40% of available RAM. LibreOffice and unoserver need additional memory on top of the JVM — less than 4 GB free causes startup failures or OOM kills.

## Installation

1. Go to **Settings → Add-ons → Add-on Store** in Home Assistant.
2. Open the menu (⋮) and select **Repositories**, then add this repository URL.
3. Find **Stirling-PDF Fat** and click **Install**.
4. Start the add-on and open the Web UI.

The first install takes several minutes to download the image.

## Configuration

| Option | Default | Description |
|---|---|---|
| `enable_login` | `false` | Turn on built-in authentication for multi-user setups. |
| `langs` | `en_GB` | Comma-separated Tesseract language codes, e.g. `en_GB,fra,deu`. |
| `log_level` | `info` | Verbosity: `info`, `debug`, `warn`, or `error`. |

### Login and team features

Set `enable_login` to `true` in the add-on configuration, then add this to `/config/stirling_pdf_fat/configs/settings.yml`:

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
| Configuration and settings | `/config/stirling_pdf_fat/configs/` |
| Application logs | `/config/stirling_pdf_fat/logs/` |
| Tesseract language files | `/share/stirling_pdf_fat/tessdata/` |
| Pipeline and watched folders | `/share/stirling_pdf_fat/pipeline/` |

### Adding OCR languages

Download `.traineddata` files from the [Tesseract tessdata repository](https://github.com/tesseract-ocr/tessdata), place them in `/share/stirling_pdf_fat/tessdata/`, add the language code to the `langs` option, and restart.

### Pipeline automation

Drop PDF files into `/share/stirling_pdf_fat/pipeline/watchedFolders/`. Processed outputs land in `/share/stirling_pdf_fat/pipeline/finishedFolders/`.

## Accessing the UI

After startup, click **Open Web UI** or go to `http://homeassistant.local:8080`.

## Architecture Notes

Single-stage build on top of `stirlingtools/stirling-pdf:latest-fat`. s6-overlay and bashio are installed on the upstream image. Only `amd64` and `aarch64` are supported.

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
