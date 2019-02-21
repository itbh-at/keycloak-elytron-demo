#!/bin/bash

# Request script for keycloak-elytron-demo app.
#
# Usage:
#   ./make_req.sh message_i_want_to_see

KEYCLOAK_PATH="./servers/keycloak"
WILDFLY_PATH="./servers/wildfly"
MESSAGE="${1}"

function abs_path {
  (cd "$(dirname $1)" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}


KEYCLOAK_CLI=$(abs_path "${KEYCLOAK_PATH}")/bin/jboss-cli.sh;
WILDFLY_CLI=$(abs_path "${WILDFLY_PATH}")/bin/jboss-cli.sh;

#first shutdown server if they run
$KEYCLOAK_CLI --connect --controller=localhost:10090 command=:shutdown
$WILDFLY_CLI --connect command=:shutdown 

sleep 20

#run them again
${KEYCLOAK_PATH}/bin/standalone.sh &
${WILDFLY_PATH}/bin/standalone.sh &

sleep 30

#compile our module
mvn install wildfly:deploy

#make call
RESULT=`curl -X POST -H "Content-Type: application/x-www-form-urlencoded" http://localhost:8180/auth/realms/keycloak-elytron-demo/protocol/openid-connect/token -d "username=demo" -d "password=demo" -d "grant_type=password" -d "client_id=curl"`
JWT=`echo $RESULT | sed 's/.*access_token":"//g' | sed 's/".*//g'`

curl -H "Authorization: Bearer $JWT" http://localhost:8080/keycloak-elytron-demo/v0/echo/${MESSAGE}
