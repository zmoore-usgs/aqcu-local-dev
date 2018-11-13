# AQCU Development Pack
A set of scripts, configuration, and other utilities to aid in setting up the AQCU development environment.

## Making changes and GitIgnore
In order to help prevent accidental commiting of secrets and other non-public configuration this project provides reference configuration files for tomcat and docker that should be copied (as explained in the setup steps below) and then modified for local use from the copies. The .gitignore for this project is setup to ignore the following directories created during the setup steps below:

- aqcu-local-dev/docker/*
- aqcu-local-dev/tomcat/aqcu/*
- aqcu-local-dev/tomcat/nwisra/*
- aqcu-local-dev/tomcat/conf-reference/aqcu/webapps/*
- aqcu-local-dev/tomcat/conf-reference/nwisra/webapps/*

If you want to make changes to the configuration that is persisted and can be used by future users of this project you should make those changes to the equivalent file(s) in one of these directories. **Please be sure to not commit any secret values or other non-public configuration (passwords, usernames, internal URLs, etc.).**

- aqcu-local-dev/docker-reference/* (Docker configuration and secrets)
- aqcu-local-dev/tomcat/conf-reference/* (*Other than /webapps) (AQCU Legacy Tomcat and NWIS-RA Tomcat configuration)

## Setup

### Copy Reference Docker Configuration
The docker configuration is currently located in `aqcu-local-dev/docker/`. This represents the reference configuration and is what users of this project should start from. Any local configuration changes you want to make should be done to your files in `aqcu-local-dev/docker/` as these are the ones that will be read by the docker-compose file. Take care not to commit any secrets if you make changes to these configuration files.

### Set up the Tomcat Instances
Follow the steps in the README located in the tomcat sub-directory of this project.

### Build and Copy Tomcat WARs
Unlike the dockerized services which are pre-built and ready to use you must build (or download from our Nexus using the provided shell scripts in the `tomcat/conf-reference/{aqcu or nwisra}` subdirectories) the WARs for the AQCU legacy Tomcat and NWIS-RA Tomcat and place them into the respective webapps directories of those tomcat instances with the correct file names (generally just involves removing build info from the built WARs like the version number and `SNAPSHOT`. The files to copy are listed here.

Git Repos for the projects to build these WAR files:

AQCU: https://github.com/USGS-CIDA/AQCU
NWIS-RA: https://github.com/USGS-CIDA/NWIS-VISION-GUI

#### AQCU Legacy Tomcat
 - AQCU Calc --> aqcu-calc.war
 - AQCU Data Retrieval --> aqcu-data-retrieval.war
 - AQCU Proc Split --> aqcu-proc-split.war
 - AQCU Renderer --> aqcu-renderer.war
 - AQCU Report Gen --> aqcu-report-gen.war
 - AQCU Webservice --> aqcu-webservice.war
 - AQCU XForm --> aqcu-xform.war
 - AQCU Data Synchronizer --> operator.war

#### NWIS-RA Tomcat
 - Reporting UI --> reporting-ui.war
 - Reporting WS Core --> reporting-ws-core.war

### Import Certs
Navigate to /ssl/ and run the create_keys.sh script to generate wildcard certs. Then import the wildcard.crt to the Java cacerts (or provide the tomcats with a custom truststore) 
as done here (prior to running this command ensure that your $JAVA_HOME environment variable is properly set to the JDK you intend to use for running the tomcat instances - if it is not set you may need to set it manually):

```
cd ./ssl/
$JAVA_HOME/bin/keytool -import -file ./wildcard.crt -keystore $JAVA_HOME/jre/lib/security/cacerts -alias aqcu-localhost
```

### Configuration Values to change:
Note that anything currently configured with `https://localhost:9999` is done because those endpoints are not really necessary to get AQCU up and running locally. They are primarily used for links within the UI or within reports, but are not used functionally by the application at all. They can be optionally set to real values if desired, but it is unecessary and will essentially have no impact on the system.

#### docker/config/common/config.env
 - aquariusServiceEndpoint - The endpoint of the Aquarius system that you want to connect to (_without_ /AQUARIUS/)
 - aquariusServiceUser - The username for the Aquarius tier you're connecting to

#### docker/secrets/common/secrets.env
 - aquariusServicePassword - The password for the Aquarius tier you're connecting to
 
#### tomcat/aqcu/conf/context.xml
 - aquarius.service.endpoint - The endpoint of the Aquarius system that you want to connect to (_with_ /AQUARIUS/)
 - aquarius.service.user - The username for the Aquarius tier you're connecting to
 - aquarius.service.password - The password for the Aquarius tier you're connecting to

#### tomcat/aqcu/conf/server.xml
 - 8446 Connector Keystore Path - The absolute (non-relative) path to the keystore bundled with this project (./ssl/keystore)

#### tomcat/nwisra/conf/context.xml
 - OracleDB Resource URL/Database/Username/Password - The connection info for the NatDB instance you want to connect to.

#### tomcat/nwisra/conf/server.xml
 - 8444 Connector Keystore Path - The absolute (non-relative) path to the keystore bundled with this project (./ssl/keystore)

## Running

Because there are inter-dependencies between services the startup order is very important. It is recommended to wait for one terminal command to fully startup before exectuing the next command.

### Terminal 1: `sudo docker-compose up water-auth rabbitmq rserve`
 - Starts Water Auth, Repgen, and RabbitMQ (required dependencies for other services)
### Terminal 2: `cd tomcat/nwisra/bin && ./catalina.sh start && tail -f ../logs/catalina.out`
 - Starts NWIS-RA
### Terminal 3: `sudo docker-compose up`
 - Starts aqcu-gateway, aqcu-ui, aqcu-lookups, aqcu-java-to-r, aqcu-tss-report, aqcu-dv-hydro-report (which is also used for the 5Yr report), aqcu-dc-report, aqcu-corr-report, aqcu-srs-report, aqcu-ext-report, aqcu-uv-hydro-report, aqcu-svp-report, and aqcu-vdi-report. You can specify which of the report services to start up specifically after _sudo docker-compose up_, in case you have memory limitations. Starting all services may overwhelm your VM/machine. For example to start just one report, _sudo docker-compose up aqcu-gateway aqcu-ui aqcu-lookups aqcu-java-t-r aqcu-tss-report_
### Terminal 4: `cd tomcat/aqcu/bin && ./catalina.sh start && tail -f ../logs/catalina.out`
 - Starts AQCU Legacy Tomcat

**IMPORTANT NOTE**
Once you have started all 4 terminals you should first visit the URL of the aqcu-gateway Swagger (see below in the service info section) to get your browser to trust the self-signed cert of the gateway which will allow the UI to later make Cross-Origin requests to it. Without accepting this self-signed cert first you may see requests from the UI to the gateway fail due to CORS. If, even after accepting the gateway cert, you still see CORS issues you should delete your AQCU Gateway docker image (`docker-compose down && docker images` then find the ID of the aqcu-gateway image and do `docker image rm <image id>`) and allow it to be re-pulled from Artifactory.

After completing these steps you should be able to access the AQCU UI by visiting: https://localhost:8445/timeseries

## Service Info
**Note**: Many of the launch commands here will not properly work until you follow the setup steps above.

_Dependencies_: Services that must be running before this service can even start up.

_Services Used_: Services that must be running for this service to be fully functional.

#### water-auth
 - Individual Launch Command: `sudo docker-compose up water-auth`
 - Dependencies: None
 - Services Used: None
 - Port: 8443
 - Context Path: /auth
 - Test URL: https://localhost:8443/auth

#### rabbitmq
 - Individual Launch Command: `sudo docker-compose up rabbitmq`
 - Dependencies: None
 - Services Used: None
 - Port: 15672
 - Context Path: /
 - Test URL: http://localhost:15672/

#### rserve
 - Individual Launch Command: `sudo docker-compose up rserve`
 - Dependencies: None
 - Services Used: None
 - Port: 6311
 - Context Path: /
 - Test URL: http://localhost:6311/ (no page will load but you should see it trying to load data, rather than immediately erroring)

#### aqcu-gateway
 - Individual Launch Command: `sudo docker-compose up aqcu-gateway`
 - Dependencies: water-auth
 - Services Used: water-auth, aqcu-lookups, aqcu-tss-report, aqcu-dv-hydro-report, AQCU Legacy Tomcat
 - Port: 7499
 - Context Path: /
 - Test URL: https://localhost:7499/swagger-ui.html

#### aqcu-java-to-r
 - Individual Launch Command: `sudo docker-compose up aqcu-java-to-r`
 - Dependencies: rserve
 - Service Used: rserve
 - Port: 7500
 - Context Path: /
 - Test URL: https://localhost:7500/swagger-ui.html

#### aqcu-lookups
 - Individual Launch Command: `sudo docker-compose up aqcu-lookups`
 - Dependencies: water-auth
 - Service Used: water-auth, Aquarius
 - Port: 7503
 - Context Path: /
 - Test URL: https://localhost:7503/swagger-ui.html and https://localhost:7503/lookup/computations

#### aqcu-ui
 - Individual Launch Command: `sudo docker-compose up aqcu-ui`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-gateway
 - Port: 8445
 - Context Path: /timeseries
 - Test URL: https://localhost:8445/timeseries

#### aqcu-corr-report
 - Individual Launch Command: `sudo docker-compose up aqcu-corr-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7505
 - Context Path: /
 - Test URL: https://localhost:7505/swagger-ui.html

#### aqcu-ext-report
 - Individual Launch Command: `sudo docker-compose up aqcu-ext-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7507
 - Context Path: /
 - Test URL: https://localhost:7507/swagger-ui.html

#### aqcu-dv-hydro-report (and 5Yr)
 - Individual Launch Command: `sudo docker-compose up aqcu-dv-hydro-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius, NWIS-RA
 - Port: 7502
 - Context Path: /
 - Test URL: https://localhost:7502/swagger-ui.html

#### aqcu-srs-report
 - Individual Launch Command: `sudo docker-compose up aqcu-srs-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7506
 - Context Path: /
 - Test URL: https://localhost:7506/swagger-ui.html

#### aqcu-svp-report
 - Individual Launch Command: `sudo docker-compose up aqcu-svp-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7509
 - Context Path: /
 - Test URL: https://localhost:7509/swagger-ui.html

#### aqcu-tss-report
 - Individual Launch Command: `sudo docker-compose up aqcu-tss-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7501
 - Context Path: /
 - Test URL: https://localhost:7501/swagger-ui.html

#### aqcu-uv-hydro-report
 - Individual Launch Command: `sudo docker-compose up aqcu-uv-hydro-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius, NWIS-RA
 - Port: 7508
 - Context Path: /
 - Test URL: https://localhost:7508/swagger-ui.html

#### aqcu-vdi-report
 - Individual Launch Command: `sudo docker-compose up aqcu-vdi-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7510
 - Context Path: /
 - Test URL: https://localhost:7510/swagger-ui.html

#### NWIS-RA Tomcat (must manually build and copy WARs as described below)
 - Individual Launch Command: `cd tomcat/nwisra/bin && ./catalina.sh start && tail -f ../logs/catalina.out`
 - Dependencies: water-auth
 - Services Used: water-auth, NatDB
 - Port: 8444
 - Context Path: /
 - Test URL: https://localhost:8444/reporting-ws-core/service

#### AQCU Legacy Tomcat (must manually build and copy WARs as described below)
 - Individual Launch Command: `cd tomcat/aqcu/bin && ./catalina.sh start && tail -f ../logs/catalina.out`
 - Dependencies: rabbitmq, NWIS-RA Tomcat
 - Service Used: rabbitmq, NWIS-RA Tomcat, rserve, Aquarius
 - Port: 8446
 - Context Path: /timeseries
 - Test URL: https://localhost:8446/aqcu-webservice/service/health
