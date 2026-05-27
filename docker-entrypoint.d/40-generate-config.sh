#!/bin/sh
set -eu

: "${APP_VENTAS_API_URL:=http://localhost:8082/api/v1}"
: "${APP_DESPACHOS_API_URL:=http://localhost:8081/api/v1}"

envsubst '$APP_VENTAS_API_URL $APP_DESPACHOS_API_URL' \
  < /opt/config-templates/config.template.js \
  > /usr/share/nginx/html/config.js
