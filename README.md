# Requirements

- Java 8
- Keycloak 4.8.3.Final
- Wildfly 15.0
- keycloak wildfly adapter 4.8.3.Final

# Installation

First download project from git
```
git clone https://gitlab.devops.cloud.itbh.at/itbh/keycloak-elytron-demo.git
```

Enter into project and create "servers" folder.Copy and unpack keycloack and wildfly 
servers here
```
cd keycloak-elytron-demo
mkdir servers
cd servers
unzip wildfly-<version>.zip && mv wildfly-<version> wildfly
unzip keycloak-4.8.3.Final.zip && mv keycloak-4.8.3.Final.zip keycloak
```

Change port on keycloak in standalone.xml (port offset) so it will not block 
with wildfly. In this README we persume port 8180 (port-offset 100)

Run keycloak
```
sh servers/keycloak/bin/standalone.sh
```
You should reach keycloak site at http://localhost:8180
Please set admin password here. Then you can login in master realm.

In keycloak backend do following
- create new realm called "keycloak-elytron-demo"
- create role called "rest"
- set rest role in Realm -> Default roles as default role
- create new client called "curl" whose settings are
  - Client protocol: openid-connect
  - Access Type: public
  - Valid redirect URLs: http://localhost
- create new client "keycloak-elytron-demo" whose settings are
  - Client protocol: openid-connect
  - Access Type: bearer-only
  - set credentials in Credentials tab.
- create user called "demo" with password "demo"
  - login as this demo user into system otherwise throw keycloak Not authorized error bei JWT token requests

Client "curl" is used for curl command for requesting access token. This token will then be send in Authorized header
to keycloak-elytron-demo app's endpoint. Application itself use client "keycloak-elytron-demo" whose type is bearer-only which
means app will not contact keycloak server itself but only check access_token. If it contains required roles it allows respective traffic.

Now run script switch_adapter.sh with parameters for "wildfly folder" "keycloack-wildfly-adapter path" and type of adapter which will be used "legacy" or "elytron"
```
sh scripts/switch_adapter.sh servers/wildfly /Users/zami/Downloads/keycloak-wildfly-adapter-dist-4.8.3.Final.zip legacy
```

At the and make simple request to app endpoint which is allowed only for clients which posses rest permission in access_token.
```
sh scripts/make_req.sh
```

You should see the result "message_from_app"

