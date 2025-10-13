create_backing_store() {
  fallocate -l ${args[--size]} "$HOME/${args[name]}"
  chmod og-rwx "$HOME/${args[name]}"
  # make the file immutable (might not be desirable)
  # chattr +i "$backing_store"
  loop_path=$(losetup --show -fP "$HOME/${args[name]}")
  echo ',,c,*' | sfdisk "$loop_path"

  case ${args[--file-system]} in
    "fat32")
      if [[ -n "${args[--label]}" ]]; then
          mkfs.vfat -F 32 -n "${args[--label]}" "${loop_path}p1"
      else
          mkfs.vfat -F 32 "${loop_path}p1"
      fi
      ;;
    "ntfs")
      if [[ -n "${args[--label]}" ]]; then
          mkfs.ntfs -L "${args[--label]}" "${loop_path}p1"
      else
          mkfs.ntfs "${loop_path}p1"
      fi
      ;;
    "exfat")
      if [[ -n "${args[--label]}" ]]; then
          mkfs.exfat -L "${args[--label]}" "${loop_path}p1"
      else
          mkfs.exfat "${loop_path}p1"
      fi
      ;;
  esac
  losetup -d "$loop_path"
}

mount_backing_store(){
    loop_path=$(losetup --show -fP $HOME/${args[name]})
    mkdir -p "/mnt/${args[name]}"
    mount "${loop_path}p1" "/mnt/${args[name]}"
}

umount_backing_store(){
    umount "/mnt/${args[name]}"
    losetup -d "$loop_path"
}

configure_device(){
  mkdir -p "/sys/kernel/config/usb_gadget/${args[name]}"
  cd "/sys/kernel/config/usb_gadget/${args[name]}" || exit 1
  echo ${args[--vendor-id]} > idVendor
  echo ${args[--product-id]} > idProduct
  echo 0x0100 > bcdDevice
  echo 0x0200 > bcdUSB
  echo 0xEF > bDeviceClass
  echo 0x02 > bDeviceSubClass
  echo 0x01 > bDeviceProtocol
  mkdir -p strings/0x409
  echo ${args[--serial-number]} > strings/0x409/serialnumber
  echo ${args[--manufacturer]} > strings/0x409/manufacturer
  echo ${args[--product]} > strings/0x409/product
  # init device config
  mkdir -p configs/c.1/strings/0x409
  echo "Config 1: Mass Storage" > configs/c.1/strings/0x409/configuration
  echo 250 > configs/c.1/MaxPower
  # Windows specific stuff
  echo "MSFT100" > os_desc/qw_sign
  echo 0xcd > os_desc/b_vendor_code # some use 0xcd
  echo 1 > os_desc/use
  # configure mass storage gadget see (https://www.kernel.org/doc/html/latest/admin-guide/abi-testing.html#abi-config-usb-gadget-gadget-functions-mass-storage-name-lun-name)
  mkdir -p functions/mass_storage.usb0
  echo 1 > functions/mass_storage.usb0/stall
  echo 0 > functions/mass_storage.usb0/lun.0/cdrom
  echo 0 > functions/mass_storage.usb0/lun.0/ro
  echo 0 > functions/mass_storage.usb0/lun.0/nofua
  echo 1 > functions/mass_storage.usb0/lun.0/removable
  echo ${args[--manufacturer]} > functions/mass_storage.usb0/lun.0/inquiry_string
  echo "$HOME/${args[name]}" > functions/mass_storage.usb0/lun.0/file
  ln -s functions/mass_storage.usb0 configs/c.1/
  udevadm settle -t 5 || :
}

if test -f $HOME/${args[name]}; then
  red "$HOME/${args[name]} already exists"
  red "No backing store will be created, but the existing one reused."
else
  create_backing_store
fi

configure_device
echo "${args[name]} successfully created"
