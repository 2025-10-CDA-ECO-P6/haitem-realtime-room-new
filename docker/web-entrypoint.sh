#!/bin/sh
set -e

# 1) Si Render fournit API_ORIGIN, on l'utilise tel quel (priorité)
# Sinon, on tombe sur API_HOSTPORT et on construit une URL.
if [ -n "${API_ORIGIN:-}" ]; then
  echo "API_ORIGIN provided by env: $API_ORIGIN"
else
  : "${API_HOSTPORT:=api:3000}"

  case "$API_HOSTPORT" in
    http://*|https://*)
      API_ORIGIN="$API_HOSTPORT"
      ;;
    *)
      API_ORIGIN="http://$API_HOSTPORT"
      ;;
  esac
fi

export API_ORIGIN

echo "Using API_HOSTPORT=${API_HOSTPORT:-<not set>}"
echo "Using API_ORIGIN=$API_ORIGIN"

# 2) Générer la conf Nginx depuis le template
envsubst '${API_ORIGIN}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

echo "----- /etc/nginx/conf.d/default.conf -----"
cat /etc/nginx/conf.d/default.conf
echo "------------------------------------------"

# 3) Fail fast si conf invalide
nginx -t

exec nginx -g "daemon off;"