#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

docker run --rm -d -p 8444:443 -v $DIR/.travis/nginx.conf:/etc/nginx/nginx.conf -v $DIR/ssl/wildcard.crt:/etc/nginx/wildcard.crt -v $DIR/ssl/wildcard.key:/etc/nginx/wildcard.key --name nginx nginx:latest

sleep 5

NGINX_ADDRESS=${NGINX_ADDRESS:-localhost}
export IMAGES="
water_auth_server
aqcu/aqcu-repgen:latest
aqcu/aqcu-ui:latest
aqcu/aqcu-gateway:latest
aqcu/aqcu-java-to-r:latest
aqcu/aqcu-corr-report:latest
aqcu/aqcu-dc-report:latest
aqcu/aqcu-dv-hydro-report:latest
aqcu/aqcu-ext-report:latest
aqcu/aqcu-srs-report:latest
aqcu/aqcu-svp-report:latest
aqcu/aqcu-tss-report:latest
aqcu/aqcu-uv-hydro-report:latest
aqcu/aqcu-vdi-report:latest
aqcu/aqcu-lookups:latest
"

for IMAGE in $IMAGES; do
  docker pull $NGINX_ADDRESS:8444/$IMAGE
  docker tag $NGINX_ADDRESS:8444/$IMAGE cidasdpdasartip.cr.usgs.gov:8447/$IMAGE
done

docker kill nginx
