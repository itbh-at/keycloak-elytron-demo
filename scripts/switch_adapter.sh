#!/bin/bash

# Setup script for Wildfly
#
# Usage:
#   ./swith_adapter.sh <path to wildfly home without a trailing slash> <keycloack-adapter-zip-path> <adapter-type>

function abs_path {
  (cd "$(dirname $1)" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]
then
    echo
    head -n 6 $(abs_path $0) | tail -n +3
    echo
    exit
fi

JBOSS_CLI=$(abs_path "${1}")/bin/jboss-cli.sh;

# 0 .. running, > 0 .. not running
$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running
JBOSS_ALREADY_RUNNING=$?

function wait_for_server() {
  until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do
    sleep 5
  done
}

# find out if keycloak was ever installed

WILDFLY_ABS_PATH=$(abs_path "${1}")
STANDALONE_XML=${WILDFLY_ABS_PATH}/standalone/configuration/standalone.xml
TYPE=${3:-adapter-install-offline.cli}
if [ "${3}" == "legacy" ];then
 TYPE="adapter-install-offline.cli"
fi

if [ "${3}" == "elytron" ];then
 TYPE="adapter-elytron-install-offline.cli"
fi


if ! grep -Fq keycloak ${STANDALONE_XML}
then
	echo "First time installation"
	#backup standalone.xml first
	cp -p ${STANDALONE_XML}{,-bckp}
fi

if [ -f "${STANDALONE_XML}" ];then
   #copy original
   cp -p ${STANDALONE_XML}-bckp ${STANDALONE_XML}
fi

# Install keycloack in offline mode (before port-offset)
KEYCLOACK_ADAPTER_PATH=${2}
KEYCLOACK_FILE=$(basename ${KEYCLOACK_ADAPTER_PATH})

if [[ "${JBOSS_ALREADY_RUNNING}" -eq "0" ]]
then
	echo "Stopping wildfly"
	${JBOSS_CLI} --connect command=:shutdown
fi


if [ -e ${KEYCLOACK_ADAPTER_PATH} ] && [ -n ${KEYCLOACK_FILE} ];then
   echo "Unpacking  keycloack adapter"
   cp -p "${KEYCLOACK_ADAPTER_PATH}" "${1}/"
   cd "${1}"
   unzip ${KEYCLOACK_FILE}
   echo "Installing keycloack adapter"
   ./bin/jboss-cli.sh  --file=bin/${TYPE}
fi

#go back
cd -

exit 0
