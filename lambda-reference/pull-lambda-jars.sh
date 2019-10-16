#!/bin/bash

mkdir -p jars

artifacts=(
  gw-vrstat-report
)

pull_from_artifactory() {
    repo_url="https://cida.usgs.gov/artifactory/aqcu-maven-centralized/gov/usgs/aqcu"
    artifact=$1
    uri_formatted_group=`echo $group | tr . /`
    version=`curl -k -s $repo_url/"$(echo "$group" | tr . /)"/$artifact/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`
    resource_endpoint="${repo_url}/${artifact}/${version}/${artifact}-${version}-aws.jar"

    echo "$(date) | Start fetch $resource_endpoint"
    curl -v --no-tcp-nodelay -o ${artifact}.jar -X GET "${resource_endpoint}"
    echo "$(date) | End fetch $resource_endpoint"
    echo "$(date) | Start fetch checksum"
    curl --no-tcp-nodelay -o ${artifact}.md5 -X GET "${resource_endpoint}.md5"
    echo "$(date) | End fetch checksum"
    artifact_md5=$(md5sum ${artifact}.jar | awk '{ print $1 }')
    remote_md5=$(cat ${artifact}.md5)
    test $artifact_md5 == $remote_md5
    if [ $? -ne 0 ]; then
    echo "A problem has occurred while downloading artifact from ${resource_endpoint}"
    echo "Downloaded artifact MD5: ${artifact_md5}"
    echo "Expected MD5: ${remote_md5}"
    exit 1
    else
    echo "Artifact retrieved from ${resource_endpoint} verified to be valid."
    mv $artifact.jar ./jars/$artifact.jar
    fi
    rm -rf $artifact.md5
}

for artifact in "${artifacts[@]}"; do
  echo "Pulling ${artifact}"
  pull_from_artifactory ${artifact}
done