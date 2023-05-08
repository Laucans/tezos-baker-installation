# Goal

Target is to simplify baker setup on tezos by automatizing it. 
This script is interactive, you'll be prompted.

# Before running script : 

## System Requirements

[x] CPU: Running with at least 2 cores is recommended
[x] Memory: Recommended RAM for running a Tezos Node is 8GB
[x] Disk: 100 GB SSD (SSD is highly recommended over HDD)
[x] Unix debian based distro
[x] Ledger Nano S or X

## Ledger can be read by plugdev group
Verify than member of plugdev group can read your ledger with
```
getfacl /dev/bus/usb/XXX/YYY
```

if no do :
```
sudo echo 'SUBSYSTEM=="usb", GROUP="plugdev", MODE="0660"' > /etc/udev/rules.d/50-myusb.rules
sudo udevadm control --reload-rules
sudo service udev restart
```
and replug your ledger

## Ledger is ready

 Tezos wallet is installed on your ledger
 Tezos baker app is installed on your ledger 
 Tezos baker app is launched on your ledger
 Tezos baker app watermark
see https://www.coincashew.com/coins/overview-xtz/guide-how-to-setup-a-baker/configure-ledger-nano-s

# Script flow
Script use configuration in `script_conf.json`
- Create baker user 
- Download latest octez binaries
- Setup private tezos node using systemd
- Bootstrap tezos node from snapshot
- Setup baker using systemd
- Setup accuser using systemd
- Prepare ledger wallet to bake
- Subscribe wallet as baker on tezos chain

# Script configuration

See script_conf.json.dist

# After restarting your machine

In case of restart, your node gonna bootstrap missed block and you will be ready.
As soon as `octez-client bootstrapped` command will return true you'll have to manually relaunch the baking app on your ledger. 

After entering your ping and open the tezos baker app run
`octez-client  -d /home/$baker_user/$baker_home setup ledger to bake for $ledger_pk_name` where `baker_user` `baker_home` and `ledger_pk_name` are defined in your `script_conf.json` 
