mapfile -d $'\0' gadgets < <(find /sys/kernel/config/usb_gadget -maxdepth 1 -mindepth 1 -type d -print0)
names=()
vendor_ids=()
manufacturers=()
product_ids=()
products=()
serial_numbers=()
file_systems=()


for gadget in "${gadgets[@]}"
do
    names+=("$(basename $gadget)")
    vendor_ids+=("$(cat $gadget/idVendor)")
    manufacturers+=("$(cat $gadget/strings/0x409/manufacturer)")
    product_ids+=("$(cat $gadget/idProduct)")
    products+=("$(cat $gadget/strings/0x409/product)")
    serial_numbers+=("$(cat $gadget/strings/0x409/serialnumber)")
done

# print table with info
printf "%-15s | %-6s | %-15s | %-6s | %-15s | %-15s\n" "Name" "VID" "Manufacturer" "PID" "Product String" "Serial Number"
printf '%s\n' "----------------|--------|-----------------|--------|-----------------|-----------------"

# Print rows
for ((i=0; i<${#gadgets[@]}; i++)); do
    printf "%-15s | %-6s | %-15s | %-6s | %-15s | %-15s\n" "${names[i]}"  "${vendor_ids[i]}" "${manufacturers[i]}" "${product_ids[i]}" "${products[i]}" "${serial_numbers[i]}"
    printf '%s\n' "----------------|--------|-----------------|--------|-----------------|-----------------"
done