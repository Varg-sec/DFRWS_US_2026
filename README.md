# Raspberry-Pi USB Spoofing

Allows the creation of USB gadgets on a Raspberry Pi system with a single bash
script. Go to the release page to download the complete script or use
[Bashly](https://bashly.dev/) to generate it on your own.

Some preliminary setup steps are required, before the USB spoofing can start.

## Installation

1. Install Raspberry Pi OS Lite on the Raspberry Pi
2. Add `dtoverlay=dw2` to `boot/firmware/config.txt`
3. Remove/Comment `otg_mode=1` in `boot/firmware/config.txt`
4. Add `libcomposite` to `/etc/modules`
5. Add `modules-load=dwc2` to `/boot/firmware/cmdline.txt` behind `rootwait`
6. Copy the `usb-spoofer` script to the main users home directory

To verify your changes were applied correctly, you may run:

```console
$ usb-spoofer test
```

## Usage

```console
$ ./usb-spoofer --help
usb-spoofer - Creation of virtual USB devices on Raspberry Pi Hardware using ConfigFS.

Usage:
  usb-spoofer COMMAND
  usb-spoofer [COMMAND] --help | -h
  usb-spoofer --version | -v

Commands:
  create       Create a virtual USB gadget.
  remove       Remove a gadget
  activate     Activate a configured gadget
  deactivate   Deactivate a configured USB gadget
  list         List configured USB gadgets
  mount        Mount the backing store of the USB gadget, e.g., to transfer files.
  umount       Unmount the backing store of the USB gadget and delete the mount point
  test         Test if Pi is configured correctly

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number
```

For example, to create a USB thumb drive:

```console
# usb-spoofer create usb_1 --vendor-id="0x0951" --product-id="0x160b" --manufacturer="Kingston Technology" --product="DataTraveler 2.0 (2GB)" --serial-number="5404A6C0AFF8F170B9600284" --size="2G" --file-system="fat32" --label="MYDATA"
```

The device can be activated with and should appear as a regular USB device on
your machine:

```console
# usb-spoofer activate usb_1
```

### Raspberry Pi Zero 2 W

Make sure to connect the Raspberry Pi Zero 2 W to the correct port, as shown in
the image below, since the UDC is only connected to the USB port labeled with `USB`.

![](./media/raspi_zero_connection.JPG)

## Support

In case some feature is missing or something us broken, open an issue here on
GitLab.

## Roadmap

- [ ] support more USB devices, e.g., HID
- [ ] offer interface through systemd
