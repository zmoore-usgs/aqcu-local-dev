#!/bin/bash

mkdir -p webapps

artifacts=(
  reporting-ui
  reporting-ws-core
)

for artifact in "${artifacts[@]}"; do
  curl -L -k -o webapps/$artifact.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=${artifact}&v=LATEST&e=war"
done
