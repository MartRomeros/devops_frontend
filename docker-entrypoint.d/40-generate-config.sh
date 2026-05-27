#!/bin/sh
set -eu

: "${APP_VENTAS_API_URL:=/api/ventas}"
: "${APP_DESPACHOS_API_URL:=/api/despachos}"
: "${PRIVATE_VENTAS_API_URL:=http://localhost:8082/api/v1}"
: "${PRIVATE_DESPACHOS_API_URL:=http://localhost:8081/api/v1}"

PRIVATE_VENTAS_API_URL="${PRIVATE_VENTAS_API_URL%/}"
PRIVATE_DESPACHOS_API_URL="${PRIVATE_DESPACHOS_API_URL%/}"

export APP_VENTAS_API_URL
export APP_DESPACHOS_API_URL
export PRIVATE_VENTAS_API_URL
export PRIVATE_DESPACHOS_API_URL

envsubst '$APP_VENTAS_API_URL $APP_DESPACHOS_API_URL' \
  < /opt/config-templates/config.template.js \
  > /usr/share/nginx/html/config.js

envsubst '$PRIVATE_VENTAS_API_URL $PRIVATE_DESPACHOS_API_URL' \
  < /opt/config-templates/nginx.default.conf.template \
  > /etc/nginx/conf.d/default.conf
