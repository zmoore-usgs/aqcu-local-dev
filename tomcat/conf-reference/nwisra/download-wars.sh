mkdir -p webapps
curl -L -k -o webapps/reporting-ui.war "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.nwis.reporting&a=reporting-ui&v=LATEST&e=war"
curl -L -k -o webapps/reporting-ws-core.war "https://cida.usgs.gov/maven/service/local/artifact/maven/redirect?r=cida-public-snapshots&g=gov.usgs.nwis.reporting&a=reporting-ws-core&v=LATEST&e=war"