# Global build args — must be declared before the first FROM to be usable in FROM instructions
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23
ARG BUILD_VERSION=2.8.2

# Stage 1: Download and extract the BentoPDF Simple Mode dist release (includes
# bundled WASM). Simple Mode drops the bentopdf.com marketing UI and keeps every
# PDF tool, so it is the only build shipped here.
FROM alpine:3.21 AS dist
ARG BUILD_VERSION
# hadolint ignore=DL3018
RUN apk add --no-cache curl unzip \
    && curl -fsSL "https://github.com/alam00000/bentopdf/releases/download/v${BUILD_VERSION}/dist-simple-${BUILD_VERSION}.zip" \
       -o /tmp/bentopdf.zip \
    && unzip /tmp/bentopdf.zip -d /tmp/dist

# Stage 2: Final runtime image
FROM ${BUILD_FROM}

ARG BUILD_VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache nginx openssl bash \
    && sed -i 's/nginx:x:100:101/nginx:x:0:0/' /etc/passwd \
    && sed -i 's/^nginx:x:101:/nginx:x:0:/' /etc/group

COPY --from=dist /tmp/dist/ /usr/share/nginx/html/

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/bentopdf/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/bentopdf/finish \
    && chmod +x /etc/cont-init.d/50-ssl.sh

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

# Replaces the former config.yaml `watchdog` key. Hits the plain-HTTP health
# endpoint on 8080, which nginx answers with a literal 200 "ok".
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["/init"]
