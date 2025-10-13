loop_path=$(losetup --show -fP $HOME/${args[name]})
mkdir -p "/mnt/${args[name]}"
mount -o uid=1000,gid=1000,umask=0022,rw "${loop_path}p1" "/mnt/${args[name]}"
