#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -Eeuo pipefail

LOG_LEVEL=$(bashio::config 'log_level' 'info')
SIMPLE_MODE=$(bashio::config 'simple_mode' 'false')

if bashio::var.true "${SIMPLE_MODE}"; then
    WEBROOT=/opt/bentopdf/simple
else
    WEBROOT=/opt/bentopdf/full
fi

rm -rf /usr/share/nginx/html
ln -sfn "${WEBROOT}" /usr/share/nginx/html

bashio::log.info "Starting BentoPDF (log_level=${LOG_LEVEL}, simple_mode=${SIMPLE_MODE})"

exec nginx
