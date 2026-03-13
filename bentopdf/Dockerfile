ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23
FROM ${BUILD_FROM}

ARG BUILD_VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache nginx bash \
    && sed -i 's/nginx:x:100:101/nginx:x:0:0/' /etc/passwd \
    && sed -i 's/^nginx:x:101:/nginx:x:0:/' /etc/group

COPY --from=ghcr.io/alam00000/bentopdf-simple:2.5.0 /usr/share/nginx/html /usr/share/nginx/html

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/bentopdf/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/bentopdf/finish

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

ENTRYPOINT ["/init"]
