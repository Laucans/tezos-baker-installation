#!/bin/bash
__FOLDER__=$(dirname "$(readlink -f "$0")")

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

config_file=$1

if [ ! -f "${config_file}" ]; then
  echo " ${config_file} doesn't exist"
  exit 1
fi

rpc_port=$(jq -r '.tezos_node.rpc_port' "${config_file}")
baker_home=$(jq -r '.tezos_baker.home' "${config_file}")
baker_user=$(jq -r '.baker_user_name' "${config_file}")

if [ -z "${rpc_port}" ] || [ -z "${baker_home}" ] || [ -z "${baker_user}" ]; then
  echo "Configuration file ${config_file} need keys tezos_baker.home, tezos_node.rpc_port, baker_user_name"
  exit 1
fi

cp $__FOLDER__/conf-template/baker-conf.json.template baker-conf.json.tmp

DESTINATION=/home/$baker_user/$baker_home/config.json

if sudo test -f $DESTINATION; then
  echo "File ${DESTINATION} already exists, renaming to ${DESTINATION}.old"
  sudo mv "${DESTINATION}" "${DESTINATION}.old"
fi

sed -i "s|<baker_home>|/home/$baker_user/$baker_home|g" baker-conf.json.tmp
sed -i "s|<rpc_port>|$rpc_port|g" baker-conf.json.tmp

sudo mv baker-conf.json.tmp $DESTINATION

sudo chown $baker_user:$baker_user $DESTINATION
