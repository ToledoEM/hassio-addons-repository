# hadolint ignore=DL3007
ARG BUILD_FROM=stirlingtools/stirling-pdf:latest-ultra-lite
ARG BUILD_ARCH=amd64
ARG HA_BASE=ghcr.io/home-assistant/${BUILD_ARCH}-base:3.23

# Stage 1: pull s6-overlay + bashio from HA base (avoids curl downloads at build time)
# hadolint ignore=DL3007
FROM ${HA_BASE} AS ha-tools

# Stage 2: actual image
# hadolint ignore=DL3007
FROM ${BUILD_FROM}

COPY --from=ha-tools /init /init
COPY --from=ha-tools /command /command
COPY --from=ha-tools /package /package
COPY --from=ha-tools /etc/s6-overlay /etc/s6-overlay
COPY --from=ha-tools /usr/bin/bashio /usr/bin/bashio
COPY --from=ha-tools /usr/bin/with-contenv /usr/bin/with-contenv
COPY --from=ha-tools /usr/lib/bashio /usr/lib/bashio

# Install jq only
# hadolint ignore=DL3018
RUN apk add --no-cache jq

RUN mkdir -p /logs /configs /pipeline /usr/share/tesseract-ocr/5

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf_ultra_lite/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf_ultra_lite/finish

ARG BUILD_VERSION
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

ENTRYPOINT ["/init"]
