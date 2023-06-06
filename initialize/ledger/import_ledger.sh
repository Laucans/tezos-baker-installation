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

user=$(jq -r '.baker_user_name' "${config_file}")
baker_home=$(jq -r '.tezos_baker.home' "${config_file}")
binaries_home=$(jq -r '.octez_binaries_home' "${config_file}")
ledger_pk_name=$(jq -r '.tezos_baker.ledger_pk_name' "${config_file}")

if [ -z "${user}" ] || [ -z "${baker_home}" ] || [ -z "${binaries_home}" ] || [ -z "${ledger_pk_name}" ]; then
    echo "Configuration file ${config_file} need keys baker_user_name, tezos_baker.home, octez_binaries_home, tezos_baker.ledger_pk_name"
    exit 1
fi

while true; do
    echo "Please verify :"
    echo "- Tezos wallet is installed on your ledger"
    echo "- Tezos baker app is installed on your ledger (to install see https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/configure-ledger-nano-s)"
    echo "- Tezos baker app is launched on your ledger"
    echo "- Tezos baker app watermark"
    echo "- Ledger can be read by members of the 'plugdev' group"

    read -p "Everything is ok ? (yes/no) " reply
    case $reply in
    [Yy]es | [Yy])
        echo "We will link your ed25519 key from your ledger to configuration"
        import_ledger_command_default=$(echo "sudo -u $user /home/$user/$binaries_home/$(sudo -u $user /home/$user/$binaries_home/octez-client list connected ledgers | grep ed25519 | xargs)")
        import_ledger_command=$(echo "$import_ledger_command_default" | sed "s|octez-client|octez-client -d /home/$user/$baker_home |")
        import_ledger_command=$(echo "$import_ledger_command" | sed "s/ledger_$user/$ledger_pk_name/")
        exec $import_ledger_command

        sudo chown $user:$user /home/$user/$baker_home/public_key_hashs /home/$user/$baker_home/public_keys /home/$user/$baker_home/secret_keys

        sudo -u $user $import_ledger_command
        break
        ;;
    [Nn]o | [Nn])
        echo "You said no, please do pre-requisite and relaunch script"
        exit 111
        ;;
    *)
        echo "Invalid answer, yes or no"
        ;;
    esac
done
