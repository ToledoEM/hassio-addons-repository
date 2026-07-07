# Changelog

## 0.146.0_2

- Fixed `public_hostname` auto-detection: was querying the Supervisor's own `/info` hostname instead of the HA host's; now queries `/host/info` and requires `hassio_role: homeassistant`.
- Fixed forced `https://` redirects on the plain-HTTP web UI (e.g. `/users/sign_in`) caused by Manyfold's `config.assume_ssl` being tied to `PUBLIC_HOSTNAME` presence with no way to opt out; the add-on now drops in a Rails initializer to keep `assume_ssl` off, since this add-on has no SSL-terminating reverse proxy in front of it.

## 0.146.0_1

- Add-on Docker configuration update: add `public_hostname` option and set Manyfold's `PUBLIC_HOSTNAME`/`PUBLIC_PORT` env vars so generated links (mailer and "Open in slicer" downloads) point at a reachable host instead of `localhost`. Auto-detects the Home Assistant host from the Supervisor when left blank.

## 0.146.0

- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.146.0>

## 0.145.1

- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.145.1>
- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.145.0>

## 0.144.1

- Details: <https://github.com/manyfold3d/manyfold/tree/v0.144.1>

## 0.144.0

- Details: <https://github.com/manyfold3d/manyfold/tree/v0.144.0>

## 0.143.2

- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.143.2>

## 0.143.1

- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.143.1>

## 0.143

- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.143.0>

## 0.142
- This release allows the use of videos in preview frames, so you can show off your models in a more dynamic fashion, and also adds indexer support for the upcoming DragonFruit resin slicer VOXL file format.
- There are also a number of fixes to metadata scanning and other background jobs, as well as a large behind-the-scenes refactor of presupported relationships which will lead to some new features in the next release.
- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.142.0>

## 0.141
- This release adds a couple of new features, and a few bugfixes, as well as some internal refactoring and improved tests. You can now set a preferred "landing page", like "my models" or "all creators", as well as the current "dashboard" - and that can be site-wide, or per-user. And, due to some of that internal refactoring, we now have syntax highlighting for some text files (e.g. Javascript).
- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.141.0>

## 0.140.1
- A small bugfix release for a couple of errors recently introduced in the metadata parsing.
- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.140.1>

## 0.140.0

- Bumped to lasted version of Manyfold for both `amd64` and `aarch64`
- Details: <https://github.com/manyfold3d/manyfold/releases/tag/v0.140.0>
- Fixed Bundler `/root is not writable` warning by exporting `HOME=/config` before startup.
- Added Raspberry Pi single-user configuration example to README.

## 0.139.2

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:latest` for both `amd64` and `aarch64`.

## 0.139.1

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:latest` for both `amd64` and `aarch64`.

## 0.139.0

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:latest` for both `amd64` and `aarch64`.

## 0.138.0

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:latest` for both `amd64` and `aarch64`.

## 0.137.0

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:0.137.0` for both `amd64` and `aarch64`.
- Add funtionalities about sharing and comment federation, some implemented in 0.136.0

## 0.135.0

- Bumped upstream Manyfold image to `ghcr.io/manyfold3d/manyfold-solo:0.135.0` for both `amd64` and `aarch64`.

## 1.0.3

- Pointed add-on metadata URL to the canonical Manyfold add-on path in `ToledoEM/hassio-addons`.
- Switched add-on image repository to `ghcr.io/alexbelgium/manyfold-{arch}`.
- Pinned upstream `manyfold-solo` base images to immutable digests in `build.yaml` and `Dockerfile`.
- Restricted AppArmor capabilities to the minimal set used by startup/runtime operations.
- Optimized ownership updates in `run.sh` to skip recursive `chown` when ownership already matches.
- Switched secret-generation fallback to `hexdump`.
- Clarified Rails fallback log behavior (background workers are not started in that fallback mode).
- Clarified README installation details (explicit repository URL and host context for path creation).

## 1.0.2

- Added build metadata for Home Assistant CI compatibility:
  - `manyfold_solo/build.yaml` with multi-arch `build_from` entries
  - `image: ghcr.io/toledoem/manyfold_solo-{arch}` in `config.yaml`
- Switched Docker base wiring to Home Assistant add-on build conventions:
  - `Dockerfile` now uses `ARG BUILD_FROM` and `FROM ${BUILD_FROM}`
- Updated add-on `url` metadata to this repository path.
- Updated repository README to remove obsolete `import_path` references.
- Added ShellCheck compatibility headers (`# shellcheck shell=bash`) to s6/entry scripts using `with-contenv`.
- Removed default-valued metadata keys (`apparmor`, `boot`, `ingress`, `stage`) to satisfy add-on linter rules.

## 1.0.1

- New resource tuning options for smaller HAOS hosts:
  - `web_concurrency`
  - `rails_max_threads`
  - `default_worker_concurrency`
  - `performance_worker_concurrency`
  - `max_file_upload_size`
  - `max_file_extract_size`
- Baseline AppArmor support:
  - `apparmor: true` in add-on metadata
  - `manyfold_solo/apparmor.txt` profile
- Removed `import_path` option and runtime wiring to reduce confusion (it was not a web import endpoint).
- Kept ingress disabled and documented direct access on port `3214`.
- Host media mappings (`/share`, `/media`) are writable to support writable library paths like `/media/manyfold/models`.
- Home Assistant ingress/panel 404 issue by moving to direct web UI access model.
- Startup/runtime setup improvements:
  - Better path validation for configured library and thumbnails paths
  - Clearer startup logs and configuration summary
  - More robust secret/bootstrap handling and ownership setup
- Recommended small-server baseline (see README):
  - `web_concurrency: 1`
  - `rails_max_threads: 5`
  - `default_worker_concurrency: 2`
  - `performance_worker_concurrency: 1`

## 1.0.0

- First Home Assistant add-on packaging for Manyfold (`manyfold_solo`).
- Runs `ghcr.io/manyfold3d/manyfold-solo` with persistent data under `/config`.
- Sidebar/web UI integration on port `3214`.
- Configurable storage paths and startup path safety checks.
- Non-root runtime defaults (`puid`/`pgid`) and startup ownership handling.
