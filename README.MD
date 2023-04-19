# Before running script : 

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
