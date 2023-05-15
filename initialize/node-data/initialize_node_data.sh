#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

config_file=$1

if [ ! -f "${config_file}" ]; then
  echo "${config_file} doesn't exist"
  exit 1
fi

snapshot_URI=$(jq -r '.tezos_node.snapshot_uri' "$config_file")
baker_user=$(jq -r '.baker_user_name' "$config_file")
octez_binaries_home=$(jq -r '.octez_binaries_home' "$config_file")
node_dir=$(jq -r '.tezos_node.home' "$config_file")
data_dir=$(jq -r '.tezos_node.data_home' "$config_file")

octez_node_exec=/home/$baker_user/$octez_binaries_home/octez-node

if [ -z "${snapshot_URI}" ] || [ -z "${baker_user}" ] || [ -z "${octez_binaries_home}" ] || [ -z "${node_dir}" ]; then
  echo "Configuration file ${config_file} needs keys tezos_node.snapshot_uri, baker_user_name, octez_binaries_home, and tezos_node.home"
  exit 1
fi

data_dir_absolute_path=/home/$baker_user/$node_dir/$data_dir

if [ -d "${data_dir_absolute_path}/context" ]; then
  echo "Blockchain has already been imported, exiting"
  exit 0
else
  echo "Did not find pre-existing data, importing blockchain"
  sudo -u ${baker_user} mkdir -p "${data_dir_absolute_path}"
  snapshot_file="/home/$baker_user/$node_dir/chain.snapshot"

  sudo test ${data_dir_absolute_path}/lock && sudo rm "${data_dir_absolute_path}/lock"
  if [[ "${snapshot_URI}" == http* ]]; then
    sudo curl -L -o "${snapshot_file}" "${snapshot_URI}"
    sudo chown "${baker_user}:${baker_user}" "${snapshot_file}"
  else
    snapshot_file=$snapshot_URI
    sudo chown "${baker_user}:${baker_user}" "${snapshot_file}"
  fi

  # There is an unknown issue on octez binary when I run this command with sudo -u tezosbaker
  # The command do nothing
  # So we change user directly then exit the terminal
  sudo -u ${baker_user} ${octez_node_exec} snapshot import "${snapshot_file}" --config-file /home/$baker_user/$node_dir/config.json

  # If we want to remove the snapshot file after using it
  # sudo rm -rvf "${snapshot_file}"

  sudo find "${data_dir_absolute_path}"
  exit $?
fi
