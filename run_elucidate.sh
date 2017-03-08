#!/bin/bash

aws s3 cp $S3_SETTINGS /opt/elucidate/elucidate.settings
aws s3 cp $S3_LOG_SETTINGS /opt/elucidate/elucidate.log4j.settings

export JAVA_OPTS="-Delucidate.server.properties=file:/opt/elucidate/elucidate.settings"

cd /usr/local/tomcat/bin

./startup.sh

while true; do echo sleeping; sleep 10; done

