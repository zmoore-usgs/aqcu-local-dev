mkdir -p webapps
curl -L -k -o webapps/aqcu-calc.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-calc&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-data-retrieval.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-data-retrieval&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-proc-split.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-proc-split&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-renderer.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-renderer&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-report-gen.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-report-gen&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-webservice.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-webservice&v=LATEST&e=war"
curl -L -k -o webapps/aqcu-xform.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=aqcu-xform&v=LATEST&e=war"
curl -L -k -o webapps/operator.war -X GET "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.aqcu&a=operator&v=LATEST&e=war"