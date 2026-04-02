# hadolint ignore=DL3007
FROM stirlingtools/stirling-pdf:latest-fat

# Install s6-overlay and bashio (the HA supervisor tooling)
ARG S6_OVERLAY_VERSION=3.2.0.2
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         curl \
         xz-utils \
         jq \
    && rm -rf /var/lib/apt/lists/* \
    && ARCH="$(dpkg --print-architecture)" \
    && case "$ARCH" in \
         amd64)   S6_ARCH="x86_64"   ;; \
         arm64)   S6_ARCH="aarch64"  ;; \
         *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
       esac \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
       | tar -C / -Jxp \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
       | tar -C / -Jxp \
    && mkdir -p /usr/lib/bashio \
    && curl -fsSL "https://github.com/hassio-addons/bashio/archive/refs/heads/main.tar.gz" \
       | tar -C /usr/lib/bashio --strip-components=2 -xz bashio-main/lib \
    && ln -sf /usr/lib/bashio/bashio /usr/bin/bashio \
    && printf '#!/usr/bin/env bash\n. /usr/lib/bashio/bashio.sh\nexec "$@"\n' > /usr/bin/with-contenv \
    && chmod +x /usr/bin/with-contenv

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf_full/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf_full/finish

ARG BUILD_VERSION
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

ENTRYPOINT ["/init"]
