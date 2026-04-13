ARG BUILD_FROM=ghcr.io/manyfold3d/manyfold-solo:latest
FROM ${BUILD_FROM}

# hadolint ignore=DL3008,DL3018
RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache bash coreutils jq openssl ca-certificates; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update; \
      apt-get install -y --no-install-recommends bash coreutils jq openssl ca-certificates; \
      rm -rf /var/lib/apt/lists/*; \
    else \
      echo "Unsupported base image: missing apk/apt-get"; \
      exit 1; \
    fi

COPY run.sh /run.sh
COPY rootfs /

RUN chmod +x /run.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/manyfold/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/manyfold/finish

ENTRYPOINT ["/init"]
