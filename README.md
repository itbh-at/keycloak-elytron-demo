# Requirements

- Java 8
- Keycloak 4.8.3.Final
- Wildfly 15.0
- keycloak wildfly adapter 4.8.3.Final

# Installation

First download project from git
```
git clone https://github.com/itbh-at/keycloak-elytron-demo.git
```

Enter into project and create "servers" folder. Copy and unpack keycloack and wildfly 
servers here
```
cd keycloak-elytron-demo
mkdir servers
cd servers
unzip wildfly-<version>.zip && mv wildfly-<version> wildfly
unzip keycloak-4.8.3.Final.zip && mv keycloak-4.8.3.Final.zip keycloak
```

Change port on keycloak in standalone.xml (port offset) so it will not block 
with wildfly. In this README we assume port 8180 (port-offset 100)

Run keycloak
```
sh servers/keycloak/bin/standalone.sh
```
You should reach keycloak site at http://localhost:8180
Please set admin password here. Then you can login in master realm.

In the keycloak backend do the following
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

Client "curl" is used for curl command for requesting access token. This token will then be send in the Authorized header
to the keycloak-elytron-demo app's endpoint. The application itself uses the client "keycloak-elytron-demo" whose type is bearer-only which
means the app will not contact the keycloak server itself but only checks the access_token. If it contains the required roles it allows respective traffic.

Now run the script switch_adapter.sh with parameters for "wildfly folder" "keycloack-wildfly-adapter path" and type of the adapter which will be used: "legacy" or "elytron"
```
sh scripts/switch_adapter.sh servers/wildfly <path to keycloak>/keycloak-wildfly-adapter-dist-4.8.3.Final.zip legacy
```

At the end make a simple request to the app endpoint which is allowed only for clients which possess the rest permission in access_token.
```
sh scripts/make_req.sh message_i_want_to_see
```

You should see the result "message_i_want_to_see". This means you reached the EJB, protected by the role "rest" sucessfully

