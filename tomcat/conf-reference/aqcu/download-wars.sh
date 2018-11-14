#!/bin/bash

mkdir -p webapps

artifacts=(
  aqcu-calc
  aqcu-data-retrieval
  aqcu-proc-split
  aqcu-renderer
  aqcu-report-gen
  aqcu-webservice
  aqcu-xform
  operator
)

for artifact in "${artifacts[@]}"; do
  curl -L -k -o webapps/$artifact.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=${artifact}&v=LATEST&e=war"
done
