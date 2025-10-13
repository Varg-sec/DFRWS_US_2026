  if ! grep -q dtoverlay=dwc2 /boot/firmware/config.txt; then
    echo -e "Please add the line 'dtoverlay=dwc2' below the [all] entry"
  fi

  if grep -q "^[[:space:]]*#.*otg_mode=1" /boot/firmware/config.txt; then
    :
  elif grep -q "^[[:space:]]*otg_mode=1" /boot/firmware/config.txt; then
    echo "Please disable otg_mode in /boot/firmware/config.txt"
  else
    :
  fi

  if ! grep -q libcomposite /etc/modules; then
    echo -e "Add the line 'libcomposite' to /etc/modules"
  fi

  if ! grep -q modules-load=dwc2 /boot/firmware/cmdline.txt; then
  # add modules-load=dwc2 as the only parameter (if already exists)
    echo "Please add 'modules-load=dwc2' parameter behind 'rootwait' in /boot/firmware/cmdline.txt"
  fi