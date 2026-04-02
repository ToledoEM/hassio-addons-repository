ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23
# hadolint ignore=DL3007
FROM stirlingtools/stirling-pdf:latest AS stirling

FROM ${BUILD_FROM}

# hadolint ignore=DL3018
RUN apk add --no-cache \
      bash \
      coreutils \
      jq \
      openssl \
      ca-certificates \
      openjdk21-jre-headless

# Copy the Stirling-PDF application and its runtime assets from upstream image
COPY --from=stirling /app /app
COPY --from=stirling /scripts /scripts
COPY --from=stirling /configs /configs
COPY --from=stirling /logs /logs
COPY --from=stirling /pipeline /pipeline
COPY --from=stirling /customFiles /customFiles
COPY --from=stirling /usr/share/tesseract-ocr /usr/share/tesseract-ocr

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/stirling_pdf/finish

ARG BUILD_VERSION
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

ENTRYPOINT ["/init"]
