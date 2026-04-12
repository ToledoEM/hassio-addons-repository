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
      curl

# Install Zulu JDK 25 musl build (glibc Temurin won't run on Alpine/musl)
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ARG ZULU_VERSION=zulu25.32.17-ca-jdk25.0.2
# hadolint ignore=DL4006
RUN ARCH="$(uname -m)" \
    && case "$ARCH" in \
         x86_64)  JDK_ARCH="x64" ;; \
         aarch64) JDK_ARCH="aarch64" ;; \
         *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
       esac \
    && curl -fsSL "https://cdn.azul.com/zulu/bin/${ZULU_VERSION}-linux_musl_${JDK_ARCH}.tar.gz" \
       -o /tmp/jdk.tar.gz \
    && mkdir -p "$JAVA_HOME" \
    && tar -xzf /tmp/jdk.tar.gz -C "$JAVA_HOME" --strip-components=1 \
    && rm /tmp/jdk.tar.gz \
    && apk del curl

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
