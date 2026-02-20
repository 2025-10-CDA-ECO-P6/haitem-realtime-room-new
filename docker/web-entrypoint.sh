#!/bin/sh
set -e

# 1) Valeur par défaut (docker-compose)
: "${API_HOSTPORT:=api:3000}"

# 2) Normalisation -> API_ORIGIN doit toujours avoir http:// ou https://
case "$API_HOSTPORT" in
  http://*|https://*)
    API_ORIGIN="$API_HOSTPORT"
    ;;
  *)
    API_ORIGIN="http://$API_HOSTPORT"
    ;;
esac

export API_ORIGIN

echo "Using API_HOSTPORT=$API_HOSTPORT"
echo "Using API_ORIGIN=$API_ORIGIN"

# 3) Render template -> default.conf
envsubst '${API_ORIGIN}' \
  < /etc/nginx/templates/nginx.conf.template \
  > /etc/nginx/conf.d/default.conf

echo "----- /etc/nginx/conf.d/default.conf -----"
cat /etc/nginx/conf.d/default.conf
echo "------------------------------------------"

# 4) Check nginx config (fail fast)
nginx -t

exec nginx -g "daemon off;"