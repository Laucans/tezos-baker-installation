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

node_dir=$(jq -r '.tezos_node.home' "${config_file}")
data_dir="$(jq -r '.tezos_node.data_home' "${config_file}")"
history_mode=$(jq -r '.tezos_node.history_mode' "${config_file}")
network=$(jq -r '.network' "${config_file}")
rpc_port=$(jq -r '.tezos_node.rpc_port' "${config_file}")
metrics_port=$(jq -r '.tezos_node.metric_port' "${config_file}")
baker_user=$(jq -r '.baker_user_name' "${config_file}")
octez_binaries_home=$(jq -r '.octez_binaries_home' "${config_file}")

octez_node_exec=/home/$baker_user/$octez_binaries_home/octez-node

if [ -z "${node_dir}" ] || [ -z "${data_dir}" ] || [ -z "${history_mode}" ] || [ -z "${network}" ] || [ -z "${rpc_port}" ] || [ -z "${metrics_port}" ] || [ -z "${baker_user}" ] || [ -z "${octez_binaries_home}" ]; then
  echo "Configuration file ${config_file} need keys tezos_node.home, tezos_node.data_home, tezos_node.history_mode, network, tezos_node.rpc_port, tezos_node.metric_port, baker_user_name, octez_binaries_home"
  exit 1
fi

data_dir_absolute_path=/home/$baker_user/$node_dir/$data_dir
cp $__FOLDER__/conf-template/node-conf.json.template node-conf.json.tmp
set +x
DESTINATION=/home/$baker_user/$node_dir/config.json

if sudo test -f $DESTINATION; then
  echo "File ${DESTINATION} already exists, renaming to ${DESTINATION}.old"
  sudo mv "${DESTINATION}" "${DESTINATION}.old"
fi

sudo -u ${baker_user} ${octez_node_exec} config init -d /home/$baker_user/$node_dir

sed -i "s|<data_dir>|$data_dir_absolute_path|g" node-conf.json.tmp
sed -i "s|<network>|$network|g" node-conf.json.tmp
sed -i "s|<metrics_port>|$metrics_port|g" node-conf.json.tmp
sed -i "s|<rpc_port>|$rpc_port|g" node-conf.json.tmp
sed -i "s|<history_mode>|$history_mode|g" node-conf.json.tmp

sudo mv node-conf.json.tmp $DESTINATION

sudo chown $baker_user:$baker_user $DESTINATION
set -x
