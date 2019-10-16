# AQCU Local Development
A set of scripts, configuration, and other utilities to aid in setting up the AQCU development environment locally on Linux.

## Making changes and GitIgnore
In order to help prevent accidental commiting of secrets and other non-public configuration this project provides reference configuration files for tomcat and docker that should be copied (as explained in the setup steps below) and then modified for local use from the copies. The .gitignore for this project is setup to ignore the following directories created during the setup steps below:

- aqcu-local-dev/docker/*
- aqcu-local-dev/tomcat/nwisra/*
- aqcu-local-dev/tomcat/conf-reference/nwisra/webapps/*

If you want to make changes to the configuration that is persisted and can be used by future users of this project you should make those changes to the equivalent file(s) in one of these directories. **Please be sure to not commit any secret values or other non-public configuration (passwords, usernames, internal URLs, etc.).**

- aqcu-local-dev/docker-reference/* (Docker configuration and secrets)
- aqcu-local-dev/tomcat/conf-reference/nwisra/* (Other than /webapps) (NWIS-RA Tomcat configuration)

## Setup

### Copy Reference Docker Configuration
The docker configuration is currently located in `aqcu-local-dev/docker-reference/`. This represents the reference configuration and is what users of this project should start from. You should make a copy of this directory called `docker` in the same root directory of this project (so you'd end up with `aqcu-local-dev/docker-reference/configuration/...` and `aqcu-local-dev/docker/configuration...`). Any local configuration changes you want to make should be done to your files in `aqcu-local-dev/docker` as these are the ones that will be read by the docker-compose file and these are ignored by the gitignore.

### Set up the NWIS-RA Tomcat
If you are planning to run a UVHydrograph or DVHydrograph report you will need to setup the NWIS-RA Tomcat.
Follow the steps in the [README](/tomcat/README.md) located in the tomcat sub-directory of this project.

### Configuration Values to change:
Note that anything currently configured with `https://localhost:9999` is done because those endpoints are not really necessary to get AQCU up and running locally. They are primarily used for links within the UI or within reports, but are not used functionally by the application at all. They can be optionally set to real values if desired, but it is unecessary and will essentially have no impact on the system.

#### docker/config/common/config.env
 - aquariusServiceEndpoint - The endpoint of the Aquarius system that you want to connect to (_without_ /AQUARIUS/)
 - aquariusServiceUser - The username for the Aquarius tier you're connecting to

#### docker/secrets/common/secrets.env
 - aquariusServicePassword - The password for the Aquarius tier you're connecting to

## Running
Because there are inter-dependencies between services the startup order is important. It is recommended to wait for one terminal command to fully startup before exectuing the next command.

1. Execute `start-backing-services.sh` (execute `chmod +x start-backing-services.sh` if the script is not executable)
   - Starts: Water Auth, Repgen, and MockS3
2. [Optional] Execute: `cd tomcat/nwisra/bin && ./catalina.sh start`
   - Starts NWIS-RA
3. Execute `docker-compose up {services}`
   - Starts the services specified in {services}.
   - Choose from: aqcu-gateway, aqcu-ui, aqcu-lookups, aqcu-java-to-r, aqcu-tss-report, aqcu-dv-hydro-report (which is also used for the 5Yr report), aqcu-dc-report, aqcu-corr-report, aqcu-srs-report, aqcu-ext-report, aqcu-uv-hydro-report, aqcu-svp-report, and aqcu-vdi-report. Example: `docker-compose up aqcu-gateway aqcu-java-to-r aqcu-tss-report`

In general, to render a single kind of report you need at a minimum (in addition to the services brought up by `start-backing-services.sh`): `aqcu-gateway aqcu-java-to-r aqcu-*-report` (where * is the report you want to render). This assumes that you have a report URL that you can tweak to work locally (such as going to the Test tier, rendering a report, copying the URL, and then modifying the host/port as needed to run it locally).

The UVHydro and DVHydro services additionally require that the NWIS-RA Tomcat is running.

In order to run the UI you will additionally need: `aqcu-ui aqcu-lookups`

**IMPORTANT NOTE**
Once you have started all 4 terminals you should first visit the URL of the aqcu-gateway Swagger (see below in the service info section) to get your browser to trust the self-signed cert of the gateway which will allow the UI to later make Cross-Origin requests to it. Without accepting this self-signed cert first you may see requests from the UI to the gateway fail due to CORS.

After completing these steps you should be able to access the AQCU UI by visiting: https://localhost:8445/timeseries

## Service Info
**Note**: Many of the launch commands here will not properly work until you follow the setup steps above.

_Dependencies_: Services that must be running before this service can even start up.

_Services Used_: Services that must be running for this service to be fully functional.

#### water-auth
 - Individual Launch Command: `docker-compose up water-auth`
 - Dependencies: None
 - Services Used: None
 - Port: 8443
 - Context Path: /auth
 - Test URL: https://localhost:8443/auth

#### mock-s3
 - Individual Launch Command: `docker-compose up mock-s3`
 - Dependencies: None
 - Services Used: None
 - Port: 80
 - Context Path: /
 - Test URL: http://localhost:80 (Should list all buckets currently in the mock S3 server)

#### rserve
 - Individual Launch Command: `docker-compose up rserve`
 - Dependencies: None
 - Services Used: None
 - Port: 6311
 - Context Path: /
 - Test URL: http://localhost:6311/ (no page will load but you should see it trying to load data, rather than immediately erroring)

#### aqcu-gateway
 - Individual Launch Command: `docker-compose up aqcu-gateway`
 - Dependencies: water-auth
 - Services Used: water-auth, aqcu-lookups, aqcu-*-report, aqcu-java-to-r
 - Port: 7499
 - Context Path: /
 - Test URL: https://localhost:7499/swagger-ui.html

#### aqcu-java-to-r
 - Individual Launch Command: `docker-compose up aqcu-java-to-r`
 - Dependencies: rserve
 - Service Used: rserve
 - Port: 7500
 - Context Path: /
 - Test URL: https://localhost:7500/swagger-ui.html

#### aqcu-lookups
 - Individual Launch Command: `docker-compose up aqcu-lookups`
 - Dependencies: water-auth
 - Service Used: water-auth, Aquarius
 - Port: 7503
 - Context Path: /
 - Test URL: https://localhost:7503/swagger-ui.html and https://localhost:7503/lookup/computations

#### aqcu-ui
 - Individual Launch Command: `docker-compose up aqcu-ui`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-gateway
 - Port: 8445
 - Context Path: /timeseries
 - Test URL: https://localhost:8445/timeseries

#### aqcu-corr-report
 - Individual Launch Command: `docker-compose up aqcu-corr-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7505
 - Context Path: /
 - Test URL: https://localhost:7505/swagger-ui.html

#### aqcu-ext-report
 - Individual Launch Command: `docker-compose up aqcu-ext-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7507
 - Context Path: /
 - Test URL: https://localhost:7507/swagger-ui.html

#### aqcu-dv-hydro-report (and 5Yr)
 - Individual Launch Command: `docker-compose up aqcu-dv-hydro-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius, NWIS-RA
 - Port: 7502
 - Context Path: /
 - Test URL: https://localhost:7502/swagger-ui.html

#### aqcu-srs-report
 - Individual Launch Command: `docker-compose up aqcu-srs-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7506
 - Context Path: /
 - Test URL: https://localhost:7506/swagger-ui.html

#### aqcu-svp-report
 - Individual Launch Command: `docker-compose up aqcu-svp-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7509
 - Context Path: /
 - Test URL: https://localhost:7509/swagger-ui.html

#### aqcu-tss-report
 - Individual Launch Command: `docker-compose up aqcu-tss-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7501
 - Context Path: /
 - Test URL: https://localhost:7501/swagger-ui.html

#### aqcu-uv-hydro-report
 - Individual Launch Command: `docker-compose up aqcu-uv-hydro-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius, NWIS-RA
 - Port: 7508
 - Context Path: /
 - Test URL: https://localhost:7508/swagger-ui.html

#### aqcu-vdi-report
 - Individual Launch Command: `docker-compose up aqcu-vdi-report`
 - Dependencies: water-auth
 - Service Used: water-auth, aqcu-java-to-r, Aquarius
 - Port: 7510
 - Context Path: /
 - Test URL: https://localhost:7510/swagger-ui.html

#### NWIS-RA Tomcat
 - Individual Launch Command: `cd tomcat/nwisra/bin && ./catalina.sh start && tail -f ../logs/catalina.out`
 - Dependencies: water-auth
 - Services Used: water-auth, NatDB
 - Port: 8444
 - Context Path: /
 - Test URL: https://localhost:8444/reporting-ws-core/service
