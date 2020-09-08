#!/bin/bash

export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=POINT_ME_TO_FULL_PATH_OF_TRUSTSTORE"
export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStorePassword=changeit"