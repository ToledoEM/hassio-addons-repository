# Self-contained add-on build. The CatalogueCanvas application source lives in
# the CatalogueCanvas/CatalogueCanvas repo; it is cloned at build time (pinned by
# CC_REF) and built here, so this image no longer depends on the prebuilt
# ghcr.io/cataloguecanvas/cataloguecanvas base image.

# Repo + ref to fetch the application source from. Pinned to the app release this
# add-on version tracks, rather than floating on main — the build pipeline here
# passes only BUILD_FROM, so an unpinned ref would silently drift the built app
# away from the version in config.yaml. Bump this alongside config.yaml.
ARG CC_REPO=https://github.com/CatalogueCanvas/CatalogueCanvas.git
ARG CC_REF=v0.2.2

# --- Stage 0: fetch application source ---
FROM alpine:3.20 AS src
ARG CC_REPO
ARG CC_REF
RUN apk add --no-cache git \
    && git clone --depth 1 --branch "${CC_REF}" "${CC_REPO}" /src \
    || git clone "${CC_REPO}" /src && git -C /src checkout "${CC_REF}"

# --- Stage 1: build the React SPA (mirrors upstream Dockerfile) ---
FROM node:22-slim AS web-build
WORKDIR /app/web
COPY --from=src /src/web/package.json /src/web/package-lock.json ./
RUN npm ci
COPY --from=src /src/web/ ./
RUN npm run build

# --- Stage 2: Python runtime (mirrors upstream Dockerfile) ---
FROM python:3.14-alpine AS runtime

RUN apk add --no-cache \
    cairo \
    pango \
    gdk-pixbuf \
    shared-mime-info

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    cairo-dev \
    pango-dev \
    gdk-pixbuf-dev \
    libffi-dev

# uv, copied from its hash-pinned official image (musl static binary, Alpine-compatible).
COPY --from=ghcr.io/astral-sh/uv:0.11.26 /uv /uvx /usr/local/bin/

WORKDIR /app

COPY --from=src /src/server/pyproject.toml /src/server/uv.lock /app/server/
COPY --from=src /src/server/src /app/server/src
RUN cd server && uv sync --frozen --no-dev \
    && apk del .build-deps \
    && pip cache purge 2>/dev/null; true

COPY --from=web-build /app/web/dist /app/web/dist

COPY --from=src /src/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV CC_DATA_DIR=/data \
    CC_STATIC_DIR=/app/web/dist \
    PATH="/app/server/.venv/bin:${PATH}"

# --- HA add-on / s6-overlay wrapper layered on top of the app runtime ---
# Defaulted so a bare `docker build` works. The s6-overlay step below runs under
# `set -eux` and expands BUILD_ARCH, so leaving it unset aborts the build — which
# is what pr-check.yaml does, since it passes only BUILD_FROM. Both real build
# paths override these: build.yaml's home-assistant/builder injects BUILD_ARCH
# and BUILD_VERSION itself.
ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=0.2.2-1
ARG S6_OVERLAY_VERSION=3.2.0.2

# Bake add-on metadata into the image so run.sh can print it at startup.
ENV CC_ADDON_VERSION=${BUILD_VERSION} \
    CC_ADDON_ARCH=${BUILD_ARCH}

# s6-overlay supervision wrapper; runs as root since Supervisor mounts /data root-owned.
USER root

# hadolint ignore=DL3018
RUN apk add --no-cache bash coreutils jq openssl ca-certificates xz curl

# Install s6-overlay, mapping BUILD_ARCH to the s6-overlay release architecture.
RUN set -eux; \
    case "${BUILD_ARCH}" in \
      amd64) S6_ARCH="x86_64" ;; \
      aarch64) S6_ARCH="aarch64" ;; \
      *) echo "Unsupported BUILD_ARCH for s6-overlay: ${BUILD_ARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/s6-overlay-noarch.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz"; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    curl -fsSL -o /tmp/s6-overlay-arch.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz"; \
    tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz; \
    rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-arch.tar.xz; \
    ln -s /command/with-contenv /usr/bin/with-contenv

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/cataloguecanvas/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/cataloguecanvas/finish

WORKDIR /app/server

USER root
ENTRYPOINT ["/init"]
CMD []
