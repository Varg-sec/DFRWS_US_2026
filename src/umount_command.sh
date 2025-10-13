loop_path=$(losetup --show -fP "$HOME/${args[name]}")
umount "/mnt/${args[name]}"
rmdir "/mnt/${args[name]}"
losetup -d "$loop_path"
