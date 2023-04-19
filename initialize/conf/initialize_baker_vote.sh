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
tezos_baker_home=$(jq -r '.tezos_baker.home' "${config_file}")
tezos_baker_init_vote=$(jq -r '.tezos_baker.initial_vote' "${config_file}")

if [ -z "${baker_user}" ] || [ -z "${tezos_baker_home}" ] || [ -z "${tezos_baker_init_vote}" ]; then
  echo "Configuration file ${config_file} need keys baker_user_name, tezos_baker_home, tezos_baker_init_vote"
  exit 1
fi

sudo mkdir -p /home/$baker_user/$tezos_baker_home

if sudo test -f /home/$baker_user/$tezos_baker_home/per_block_votes.json; then
  echo {liquidity_baking_toggle_vote: $tezos_baker_init_vote} | sudo tee -a /home/$baker_user/$tezos_baker_home/per_block_vote.json
  echo "Vote has been initialized with pass, you can choose a value for the next protocol by editing file /home/${baker_user}/tezos-bake/per_block_vote.json and replace value with off on or keep pass."
  echo "For more information about vote see https://tezos.gitlab.io/alpha/liquidity_baking.html#toggle-vote"
fi
