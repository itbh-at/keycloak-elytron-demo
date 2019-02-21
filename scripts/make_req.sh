#!/bin/bash

mvn install wildfly:deploy

RESULT=`curl -X POST -H "Content-Type: application/x-www-form-urlencoded" http://localhost:8180/auth/realms/keycloak-elytron-demo/protocol/openid-connect/token -d "username=demo" -d "password=demo" -d "grant_type=password" -d "client_id=curl"`
JWT=`echo $RESULT | sed 's/.*access_token":"//g' | sed 's/".*//g'`

curl -H "Authorization: Bearer $JWT" http://localhost:8080/keycloak-elytron-demo/v0/echo/asdasd
