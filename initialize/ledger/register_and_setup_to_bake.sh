#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

config_file=$1

if [ ! -f "${config_file}" ]; then
  echo " ${config_file} doesn't exist"
  exit 1
fi

baker_user=$(jq -r '.baker_user_name' "${config_file}")
baker_home=$(jq -r '.tezos_baker.home' "${config_file}")
binaries_home=$(jq -r '.octez_binaries_home' "${config_file}")
ledger_pk_name=$(jq -r '.tezos_baker.ledger_pk_name' "${config_file}")

if [ -z "${baker_user}" ]|| [ -z "${binaries_home}" ] || [ -z "${ledger_pk_name}" ] || [ -z "${baker_home}" ]; then
  echo "Configuration file ${config_file} need keys baker_user_name, tezos_baker.home, octez_binaries_home, tezos_baker.ledger_pk_name"
  exit 1
fi

sudo -u ${baker_user} /home/$baker_user/$binaries_home/octez-client  -d /home/$baker_user/$baker_home register key $ledger_pk_name as delegate
sudo -u ${baker_user} /home/$baker_user/$binaries_home/octez-client  -d /home/$baker_user/$baker_home setup ledger to bake for $ledger_pk_name
