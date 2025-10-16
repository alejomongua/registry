#!/bin/sh
set -e

TEMPLATE="/etc/nginx/conf.d/default.conf.template"
TARGET="/etc/nginx/conf.d/default.conf"

if [ -f "$TEMPLATE" ]; then
  echo "Rendering nginx template $TEMPLATE -> $TARGET"
  # Only substitute known variables to be safe
  envsubst '${DOMAIN} ${REGISTRY_PORT}' < "$TEMPLATE" > "$TARGET"
else
  echo "Template $TEMPLATE not found, skipping render"
fi

echo "Starting nginx..."
exec nginx -g 'daemon off;'
