#!/bin/bash -ex

# Create wildcard certificates: ./create_keys.sh
# Create domain-specific certificates: ./create_keys.sh some.domain.name

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
HOSTNAME="${1:-DNS:localhost}"

rm -f $DIR/keystore || true
rm -f $DIR/tomcat.pkcs12 || true
rm -f $DIR/wildcard* || true

openssl genrsa -out $DIR/wildcard.key 2048
openssl req -nodes -newkey rsa:2048 -keyout $DIR/wildcard.key -out $DIR/wildcard.csr -extensions SAN -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nkeyUsage = nonRepudiation, digitalSignature, keyEncipherment\nbasicConstraints = CA:FALSE\nsubjectAltName=${HOSTNAME}")) \
    -subj "/C=US/ST=Wisconsin/L=Middleon/O=US Geological Survey/OU=WMA/CN=*"
openssl x509 -req \
  -extfile <(printf "keyUsage = nonRepudiation, digitalSignature, keyEncipherment\nbasicConstraints = CA:FALSE\nsubjectAltName=${HOSTNAME}") \
  -days 9999 -in $DIR/wildcard.csr -signkey $DIR/wildcard.key  -out $DIR/wildcard.crt
openssl pkcs12 -export -in $DIR/wildcard.crt -inkey $DIR/wildcard.key -name tomcat -out $DIR/tomcat.pkcs12 -password pass:changeit
keytool -v -importkeystore -deststorepass changeit -destkeystore $DIR/keystore -deststoretype JKS -srckeystore $DIR/tomcat.pkcs12 -srcstorepass changeit -srcstoretype PKCS12 -noprompt
