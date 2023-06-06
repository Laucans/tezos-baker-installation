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

octez_binaries_home=$(jq -r '.octez_binaries_home' "${config_file}")
baker_user=$(jq -r '.baker_user_name' "${config_file}")

if [ -z "${baker_user}" ] || [ -z "${octez_binaries_home}" ]; then
  echo "Configuration file ${config_file} needs keys baker_user_name and octez_binaries_home"
  exit 1
fi

output_dir=/home/$baker_user/$octez_binaries_home

sudo mkdir -p $output_dir
# Repository name
repo="serokell/tezos-packaging"

# Get the latest release tag
tag=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Download the artefacts that match the regex
for artefact_url in $(curl -s "https://api.github.com/repos/${repo}/releases/tags/${tag}" | grep '"browser_download_url":' | cut -d '"' -f 4 | grep -E 'octez-(baker|accuser)-[^\.-]+$|octez-(client|node|signer)$'); do
  echo "Downloading ${artefact_url} ..."
  artefact_name=$(basename "${artefact_url}")
  sudo curl --silent -L -o "${output_dir}/${artefact_name}" ${artefact_url}
done

sudo chmod -R 710 $output_dir
sudo chown -R $baker_user:$baker_user $output_dir

# Download sapling deps
if [ ! -f "/home/$baker_user/.zcash-params" ]; then
  sudo wget -P /home/$baker_user https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh
  sudo chown $baker_user:$baker_user /home/$baker_user/fetch-params.sh ; sudo chmod 755 /home/$baker_user/fetch-params.sh
  sudo -u $baker_user /home/$baker_user/fetch-params.sh
fi
