# Stirling-PDF Home Assistant Add-on Repository

A Home Assistant OS add-on repository that packages [Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) — a locally hosted, feature-rich PDF manipulation tool — in two variants to suit different needs.

## Add-ons

### Stirling-PDF (basic)

Lightweight install (~600 MB). Covers the most common PDF tasks with no external tool dependencies.

**Included:** merge, split, compress, rotate, watermark, sign, annotate, redact, image↔PDF conversion, pipeline automation, REST API.

**Not included:** OCR, LibreOffice conversion, Ghostscript, ImageMagick, Weasyprint.

→ [Documentation](stirling_pdf/README.md)

---

### Stirling-PDF Full

Full-featured install (~4 GB). Uses the `latest-fat` upstream image and includes every external tool Stirling-PDF supports.

**Adds over basic:** OCR (Tesseract), PDF↔Word/PowerPoint/RTF/XML (LibreOffice), compress/repair (Ghostscript + qpdf), ImageMagick compression, HTML/URL/Markdown→PDF (Weasyprint), PDF→HTML/Markdown (pdftohtml).

→ [Documentation](stirling_pdf_full/README.md)

---

## Which one should I install?

| I want to… | Use |
|---|---|
| Merge, split, rotate, watermark, sign PDFs | Basic |
| Convert Word/PowerPoint/RTF files to PDF | Full |
| Extract text from scanned PDFs (OCR) | Full |
| Run on limited storage or slow connection | Basic |
| Get every possible feature | Full |

You can install both simultaneously — they use different slugs and separate storage paths.

## Installation

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the menu (⋮) in the top right and select **Repositories**.
3. Add this repository URL and click **Add**.
4. Find **Stirling-PDF** or **Stirling-PDF Full** in the store and click **Install**.
