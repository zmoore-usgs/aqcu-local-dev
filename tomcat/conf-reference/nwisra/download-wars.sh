#!/bin/bash

mkdir -p webapps

artifacts=(
  reporting-ui
  reporting-ws-core
)

for artifact in "${artifacts[@]}"; do
  curl -L -k -o webapps/$artifact.war -X GET "https://artifactory.wma.chs.usgs.gov/artifactory/cida-public-releases/gov/usgs/nwis/reporting/${artifact}/1.25/${artifact}-1.25.war"
done
