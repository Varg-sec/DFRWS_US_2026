filter_is_root() {
    if [ "$EUID" -ne 0 ]; then
        red "Please run this script as root"
    fi
}