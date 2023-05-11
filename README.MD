# Goal

This repo contains scripts & resources to ease and automate the setup of a Tezos baker.

# Prior to running the script: 

## System Requirements

- [x] CPU: Running with at least 2 cores is recommended
- [x] Memory: Recommended RAM for running a Tezos Node is 8GB
- [x] Disk: 100 GB SSD (SSD is highly preferred over HDD)
- [x] A Unix debian-based distribution.
- [x] Ledger Nano S or X

## Ledger access and the plugdev group
Ensure that the plugdev group members have read access to your ledger using the following command:

```
getfacl /dev/bus/usb/XXX/YYY
```

If they do not have access, run the following commands:
```
sudo echo 'SUBSYSTEM=="usb", GROUP="plugdev", MODE="0660"' > /etc/udev/rules.d/50-myusb.rules
sudo udevadm control --reload-rules
sudo service udev restart
```
After running these commands, re-plug your ledger.

## Ledger Preparation

Ensure the following:

- The Tezos wallet is installed on your ledger.
- The Tezos baker app is installed on your ledger.
- The Tezos baker app is running on your ledger.
- The Tezos baker app watermark is correctly set.

Refer to [this guide](https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/configure-ledger-nano-s) for more detailed instructions.

# Script Flow
The main entrypoint script is `main_initialize_baker.sh`.

The script uses configuration details from `script_conf.json` to:
- Create a new user account dedicated to the baker.
- Download the latest Octez binaries.
- Set up a private Tezos node using systemd.
- Bootstrap the Tezos node from a snapshot.
- Set up the baker using systemd.
- Set up the accuser using systemd.
- Prepare the ledger wallet for baking.
- Register the wallet as baker on the Tezos chain.

# Script configuration

See `script_conf.json.dist`

# After restarting your machine

In case of a restart of your machine, your node will bootstrap any missed blocks, after which you will be ready to proceed.
As soon as `octez-client bootstrapped` command will return true you'll have to manually relaunch the baking app on your ledger. 

After entering your PIN and opening the Tezos baker app, run the following command:

`octez-client  -d /home/$baker_user/$baker_home setup ledger to bake for $ledger_pk_name`.
Here, `baker_user`, `baker_home`, and `ledger_pk_name` should match the values defined in your `script_conf.json`.
