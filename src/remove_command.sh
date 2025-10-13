cd "/sys/kernel/config/usb_gadget/${args[name]}"
# start cleaning up
rm configs/c.1/mass_storage.usb0
# rm configs/c.1/MaxPower # this fails
rmdir configs/c.1/strings/0x409
rmdir configs/c.1
# remove functions
rmdir functions/mass_storage.usb0
# remove strings
rmdir strings/0x409
cd $HOME
rmdir "/sys/kernel/config/usb_gadget/${args[name]}"

if [[ ${args[--keep-backing-store]:=0} == 0 ]] ; then
    rm "$HOME/${args[name]}"
fi
