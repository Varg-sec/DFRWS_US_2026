if gadget_present ${args[name]}; then
    ls /sys/class/udc/ > "/sys/kernel/config/usb_gadget/${args[name]}/UDC"
else
    red_bold "Gadget ${args[name]} was not configured"
fi
