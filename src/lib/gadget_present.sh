gadget_present(){
    if test -e /sys/kernel/config/usb_gadget/$1; then
        return 0
    else
        return 1
    fi
}

list_gadgets(){
    find /sys/kernel/config/usb_gadget -maxdepth 1 -mindepth 1 -type d
}