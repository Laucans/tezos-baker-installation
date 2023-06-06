#!/bin/bash

script_conf_filepath=$1

if [ -z "$script_conf_filepath" ]; then
    echo "Usage: $0 <script_conf_filepath>"
    exit 1
fi

function check_systemd_status {
    systemctl status $1 >>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "Systemd unit $1 is running"
    else
        echo "Systemd unit $1 is not running"
    fi
}

./initialize/script_tooling/init_tools.sh

baker_user=$(jq -r '.baker_user_name' "${script_conf_filepath}")
tezos_node_home=$(jq -r '.tezos_node.home' "${script_conf_filepath}")
tezos_node_home=$(jq -r '.tezos_node.data_home' "${script_conf_filepath}")
tezos_baker_home=$(jq -r '.tezos_baker.home' "${script_conf_filepath}")
tezos_accuser_home=$(jq -r '.tezos_accuser.home' "${script_conf_filepath}")
octez_binaries_home=$(jq -r '.octez_binaries_home' "${script_conf_filepath}")

./initialize/user/create_baker_user.sh $baker_user

echo ">> Progress: create tezos working folders"
sudo mkdir -p /home/$baker_user/$octez_binaries_home
sudo mkdir -p /home/$baker_user/$tezos_node_home
sudo mkdir -p /home/$baker_user/$tezos_node_data
sudo mkdir -p /home/$baker_user/$tezos_baker_home
sudo mkdir -p /home/$baker_user/$tezos_accuser_home

#remove ? sudo grep -qF 'export TEZOS_NODE_DIR' /home/${baker_user}/.bashrc || echo "export TEZOS_NODE_DIR=/home/${baker_user}/tezos-node/.tezos_node" | sudo tee -a /home/${baker_user}/.bashrc > /dev/null

echo ">> Progress: Stopping octez-node.service octez-baker.service octez-accuser.service if they exist and run ..."
sudo systemctl stop octez-node.service octez-baker.service octez-accuser.service

echo ">> Progress: Downloading tezos-binaries"
./initialize/tezos/download_last_tezos_binaries_into.sh $script_conf_filepath

sudo chown -R $baker_user:$baker_user /home/$baker_user/

echo ">> Progress: Use template to initialize systemd"
./initialize/systemd/initialize_systemd_config.sh $script_conf_filepath
sudo systemctl daemon-reload

echo ">> Progress: Initialize node config"
./initialize/conf/initialize_node_conf.sh $script_conf_filepath

echo ">> Progress: Initialize tezos node data"
./initialize/node-data/initialize_node_data.sh $script_conf_filepath

echo ">> Progress: Initialize vote"
./initialize/conf/initialize_baker_vote.sh $script_conf_filepath

sudo chown -R $baker_user:$baker_user /home/$baker_user/

echo ">> Progress: Enable and start octez-node.service..."
sudo systemctl enable octez-node.service
sudo systemctl start octez-node.service

echo ">> Progress: Waiting Node status"
sleep 15
check_systemd_status octez-node.service >/dev/stdout

echo ">> Progress: waiting node to be bootstrapped"
count=0
while ! sudo -u $baker_user /home/$baker_user/$octez_binaries_home/octez-client -d /home/$baker_user/$tezos_baker bootstrapped >/dev/null 2>&1; do
    sleep 10
    ((count += 1))
    if ((count % 30 == 0)); then
        echo ">> Progress: Waiting for Tezos to bootstrap, $((count / 6)) minutes passed"
    fi
done
echo ">> Progress: Tezos is now fully bootstrapped"

echo ">> Progress: Initialize baker config"
./initialize/conf/initialize_baker_conf.sh $script_conf_filepath

echo ">> Progress: Initialize accuser config"
./initialize/conf/initialize_accuser_conf.sh $script_conf_filepath

#import ledger
echo ">> Progress: Link ledger keys"
./initialize/ledger/import_ledger.sh $script_conf_filepath

echo ">> Progress: Register and setup ledger to bake"
./initialize/ledger/register_and_setup_to_bake.sh $script_conf_filepath

echo ">> Progress: Enable and start octez-baker.service octez-accuser.service"
sudo systemctl enable octez-baker.service octez-accuser.service
sudo systemctl start octez-baker.service octez-accuser.service

check_systemd_status octez-accuser.service >/dev/stdout
check_systemd_status octez-baker.service >/dev/stdout
