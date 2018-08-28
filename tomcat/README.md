# Setting Up Tomcat Instances

1. Download Tomcat 8.0.xx from: https://tomcat.apache.org/download-80.cgi
2. Unzip two instances of this tomcat into this directory and name them `aqcu` and `nwisra`. The final structures should look something like this for the tomcat launch script `bin/catalina.sh`: `aqcu-local-dev/tomcat/aqcu/bin/catalina.sh` and `aqcu-local-dev/tomcat/nwisra/bin/catalina.sh`
3. Download the ojdbc7.jar and ojdbc6.jar drivers from here: https://www.oracle.com/technetwork/database/features/jdbc/jdbc-drivers-12c-download-1958347.html
4. Place the downloaded jars into the `lib` directory of the `nwisra` tomcat instance.
5. Copy the server.xml and context.xml for each tomcat instance from the `conf/aqcu` and `conf/nwisra` subdiretories of this folder (`aqcu-local-dev/tomcat/conf/{aqcu or nwisra}`) into the respective instance's `conf` folder and replace the existing `server.xml` and `context.xml`.