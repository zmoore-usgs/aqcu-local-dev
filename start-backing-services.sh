#!/bin/bash

# Useful for environments where the Docker engine is not running on the host
# (like Docker Machine)
DOCKER_ENGINE_IP="${DOCKER_ENGINE_IP:-localhost}"

launch_services () {
  docker-compose -f docker-compose.yml up --no-color --detach --renew-anon-volumes water-auth mock-s3 rserve
}

create_s3_bucket () {
  curl --request PUT "http://${DOCKER_ENGINE_IP}:8081/aqcu-report-configs-test"
}

load_bootstrap_s3_data() {
  # ME
  upload_s3_data me/config.json me/config.json
  upload_s3_data me/sw/reports.json me/sw/reports.json
  upload_s3_data me/gw/reports.json me/gw/reports.json
  upload_s3_data me/sw/01010000/reports.json me/sw/01010000/reports.json
  upload_s3_data me/sw/01047200/reports.json me/sw/01047200/reports.json

  # MO
  upload_s3_data mo/config.json mo/config.json
  upload_s3_data mo/sw/reports.json mo/sw/reports.json
  upload_s3_data mo/gw/reports.json mo/gw/reports.json
  upload_s3_data mo/sw/07010000/reports.json mo/sw/07010000/reports.json

  # WI
  upload_s3_data wi/config.json wi/config.json
  upload_s3_data wi/sw/reports.json wi/sw/reports.json
  upload_s3_data wi/gw/reports.json wi/gw/reports.json
  upload_s3_data wi/sw/423740088592701/reports.json wi/sw/423740088592701/reports.json
}

# $1 - Path of JSON file to upload within bootstrap-report-data
# $2 - Path in S3 to upload to within aqcu-report-configs-test bucket
upload_s3_data() {
  curl --header "Content-Type: application/json" --request PUT --data "$(echo $(cat ./bootstrap-report-data/$1))" "http://localhost:8081/aqcu-report-configs-test/$2"
}

echo "Launching AQCU Backing Services..."

EXIT_CODE=$(launch_services)
if [[ $EXIT_CODE -ne 0 ]]; then
  echo "Could not launch backing services"
  exit $EXIT_CODE
fi

echo "Waiting for S3 Mock to come up..."
until curl "${DOCKER_ENGINE_IP}:8081" | grep -q "amazon"; do sleep 4; done

echo "Creating test S3 bucket..."
EXIT_CODE=$(create_s3_bucket)

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "Could not create S3 bucket"
  exit $EXIT_CODE
fi

echo "Bucket created successfully"
echo "Uploading S3 bootstrap data..."
EXIT_CODE=$(load_bootstrap_s3_data)

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "Could not load bootstrap data"
  exit $EXIT_CODE
fi

echo "Backing services launched successfully."
exit 0
