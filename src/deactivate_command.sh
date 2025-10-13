if gadget_present ${args[name]}; then
    echo "" > "/sys/kernel/config/usb_gadget/${args[name]}/UDC"
else
    red_bold "Gadget ${args[name]} is not configured"
fi
