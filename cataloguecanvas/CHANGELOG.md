# Changelog

## 0.2.2-1

- Initial release in this repository.
- Ports the CatalogueCanvas add-on from [CatalogueCanvas/cataloguecanvas-homeassistant-addon](https://github.com/CatalogueCanvas/cataloguecanvas-homeassistant-addon) (AGPL-3.0), rebuilt and published as `ghcr.io/toledoem/cataloguecanvas-{arch}` instead of using the upstream image.
- Tracks upstream add-on `0.2.2-1`, which builds application release [v0.2.2](https://github.com/CatalogueCanvas/CatalogueCanvas/blob/v0.2.2/CHANGELOG.md).
- The application source ref (`CC_REF`) is pinned to `v0.2.2` in the Dockerfile rather than floating on `main`, so the built app matches the version in `config.yaml`.
