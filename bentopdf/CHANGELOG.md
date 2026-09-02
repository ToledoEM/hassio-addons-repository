# Changelog

## 2.8.8-1

- Switch to upstream's Simple Mode build, which drops the bentopdf.com marketing UI (nav bar, hero, features, FAQ, footer) and serves only the PDF tools. All 130 tools and the LibreOffice WebAssembly payload are unchanged.
- Image size drops from roughly 252 MB to about 228 MB.
- **Breaking:** the marketing UI is no longer available. There is no option to restore it.

## 2.8.8

- Automated upstream update to 2.8.8.
- Details: <https://github.com/alam00000/bentopdf/releases/tag/v2.8.8>

## 2.8.7

- Bump version after new official image release
- This release addresses security vulnerabilities (GHSA-wh78-rcw2-hhg9, GHSA-5xjf-rr5x-pcfj, GHSA-cx8x-7rrr-r9x8) affecting all versions up to and including v2.8.6. **All users are strongly advised to upgrade to v2.8.7 immediately.**
- <https://github.com/alam00000/bentopdf/releases/tag/v2.8.7>

## 2.8.6

- Bump version after new official image release
- <https://github.com/alam00000/bentopdf/releases/tag/v2.8.6>

## 2.8.5

- Bump version after new official image release
- <https://github.com/alam00000/bentopdf/releases/tag/v2.8.5>

## 2.5.0

- Initial release of BentoPDF Home Assistant add-on
- Based on upstream BentoPDF v2.5.0
- Serves 50+ client-side PDF tools via nginx on port 8080
- Supports amd64 and aarch64
