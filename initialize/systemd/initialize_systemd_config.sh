#!/bin/bash
__FOLDER__=$(dirname "$(readlink -f "$0")")

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

config_file=$1

if [ ! -f "${config_file}" ]; then
  echo "${config_file} doesn't exist"
  exit 1
fi

user=$(jq -r '.baker_user_name' "${config_file}")
binaries_home=$(jq -r '.octez_binaries_home' "${config_file}")
tezos_node_home=$(jq -r '.tezos_node.home' "${config_file}")
baker_home=$(jq -r '.tezos_baker.home' "${config_file}")
accuser_home=$(jq -r '.tezos_accuser.home' "${config_file}")
initial_vote=$(jq -r '.tezos_baker.initial_vote' "${config_file}")
protocol=$(jq -r '.protocol' "${config_file}")
node_data_home=$(jq -r '.tezos_node.data_home' "${config_file}")

SYSTEMD_DIR="/etc/systemd/system"
TEMPLATE_DIR="$__FOLDER__/systemd-template"

# Copy service templates and replace values
for TEMPLATE in "${TEMPLATE_DIR}"/*.template; do
  SERVICE=$(basename "$TEMPLATE" .template)
  DESTINATION="${SYSTEMD_DIR}/${SERVICE}"
  TEMPLATE_TMP_FILE=$TEMPLATE.tmp
  cp $TEMPLATE $TEMPLATE_TMP_FILE

  if sudo test -f $DESTINATION; then
    echo "File ${DESTINATION} already exists, renaming to ${DESTINATION}.old"
    sudo mv "${DESTINATION}" ${DESTINATION}.old
  fi

  sed -i "s|<user>|${user}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<binaries_home>|${binaries_home}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<tezos_node_home>|${tezos_node_home}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<protocol>|${protocol}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<baker_home>|${baker_home}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<node_data_home>|${node_data_home}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<initial_vote>|${initial_vote}|g" "${TEMPLATE_TMP_FILE}"
  sed -i "s|<accuser_home>|${accuser_home}|g" "${TEMPLATE_TMP_FILE}"

  sudo mv $TEMPLATE_TMP_FILE $DESTINATION
done
