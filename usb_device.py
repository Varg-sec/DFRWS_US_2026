import argparse
import ast
import os
import random
import urllib.request
import uuid
from dataclasses import asdict, dataclass
from typing import Literal

import yaml


@dataclass
class USBDevice:
    vendor_id: str
    product_id: str
    product_name: str
    manufacturer: str = None
    serial_number: str = None
    file_system: str = None
    size: str = None
    label: str = None

    def __str__(self):
        return (
            f"vendor_id: {self.vendor_id}\n"
            f"product_id: {self.product_id}\n"
            f"product_name: {self.product_name}\n"
            f"manufacturer: {self.manufacturer}\n"
            f"serial_number: {self.serial_number}\n"
            f"file_system: {self.file_system}\n"
            f"size: {self.size}\n"
            f"label: {self.label}\n"
        )

    def __repr__(self):
        return self.__str__()


def _download_usb_ids():
    urllib.request.urlretrieve("http://www.linux-usb.org/usb.ids", "usb.ids")


def parse_usb_ids() -> list[USBDevice]:
    """Parse the list of USB IDs.

    Returns:
        list of USBDevices, representing all possible combinations of USB IDs.
    """
    if not os.path.exists("usb.ids"):
        _download_usb_ids()
    vendor_id, manufacturer = None, None
    devices = []
    with open("usb.ids", "r") as f:
        for line in f:
            if line.lstrip().startswith("#") or len(line.strip()) == 0:
                # usb.ids contains more than usb IDs, so we can break here
                if line.startswith(
                    "# List of known device classes, subclasses and protocols"
                ):
                    break
                else:
                    continue
            elif line.startswith("\t"):
                product_id, product_name = line.split()[0], " ".join(line.split()[1:])
                devices.append(
                    USBDevice(
                        vendor_id="0x" + vendor_id,
                        product_id="0x" + product_id,
                        product_name=product_name,
                        manufacturer=manufacturer,
                    )
                )
            else:
                vendor_id, manufacturer = line.split()[0], " ".join(line.split()[1:])
    return devices


def search_devices(
    devices: list[USBDevice],
    key: Literal["vendor_id", "manufacturer", "product_id", "product_name"],
    value: str,
) -> list[USBDevice]:
    """Search for specific devices in the list of USBDevices

    Args:
        devices: the list of USBDevices as returned by parse_usb_ids()
        key: which attribute of USBDevice to search for
        value: the value to search for. IDs have to be specified fully, names can be
            provided partially

    Returns:
        list of USBDevices that match the searched value
    """
    match key:
        case "vendor_id":
            return list(filter(lambda d: d.vendor_id == value, devices))
        case "manufacturer":
            return list(filter(lambda d: d.manufacturer.find(value) != -1, devices))
        case "product_id":
            return list(filter(lambda d: d.product_id == value, devices))
        case "product_name":
            return list(filter(lambda d: d.product_name.find(value) != -1, devices))
        case _:
            raise ValueError("Unknown key")


def generate_usb(device: USBDevice) -> USBDevice:
    """Generate a USB device from a list of devices.

    Args:
        device: USBDevice as extracted with parse_usb_ids()

    Returns:
        a single USBDevice with values for all attributes
    """
    device.serial_number = str(uuid.uuid4()).replace("-", "")[:16]
    device.file_system = random.choice(["fat32", "exfat", "nfts"])
    device.size = random.choice(["128M", "256M", "512M", "1G", "2G"])
    return device


def generate(args: argparse.Namespace) -> None:
    """Generate a USB device from a list of devices.

    Args:
        args: the parsed command line arguments
    """
    if args.manufacturer:
        filtered = search_devices(devices, "manufacturer", args.manufacturer)
    elif args.product_name:
        filtered = search_devices(devices, "product_name", args.product_name)
    elif args.vid:
        filtered = search_devices(devices, "vendor_id", args.vid)
    elif args.pid:
        filtered = search_devices(devices, "product_id", args.pid)
    else:
        filtered = devices

    if len(filtered) == 0:
        raise KeyError(
            f"No USB device found in usb.ids that matches you specification."
        )

    generated_devices = [
        asdict(generate_usb(random.choice(filtered))) for _ in range(args.generate)
    ]
    if args.output == "stdout":
        print(generated_devices)
    with open(args.output, "w") as f:
        yaml.dump(generated_devices, f)


def validate(args: argparse.Namespace) -> None:
    """Validate the USB information provided by the user.

    Args:
        args: the parsed command line arguments
    """
    if args.file:
        with open(args.file, "r") as f:
            devices_to_validate = yaml.safe_load(f)
    elif args.input:
        devices_to_validate: list[dict] = ast.literal_eval(args.input)
        if isinstance(devices_to_validate, dict):
            devices_to_validate = [devices_to_validate]

    for element in devices_to_validate:
        filtered = devices
        for key, value in element.items():
            if key not in ["vendor_id", "manufacturer", "product_id", "product_name"]:
                continue
            filtered = search_devices(filtered, key, value)
            if len(filtered) == 0:
                print(f"{key}: {value} not found in USB.ids")
        print(f"{element} is a valid USB device!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="USB Device Generator",
        description="Generate a USB device from a list of devices.",
    )

    subparsers = parser.add_subparsers(required=True)

    parser_generate = subparsers.add_parser(
        "generate", help="Generate the configuration of a USB device"
    )
    parser_generate.set_defaults(func=generate)
    parser_generate.add_argument(
        "-g", "--generate", type=int, default=1, help="Generate n USB device(s)"
    )
    parser_generate.add_argument(
        "-o",
        "--output",
        default="stdout",
        help="Output filepath (if empty, it prints to stdout)",
    )
    group_generate = parser_generate.add_mutually_exclusive_group()
    group_generate.add_argument(
        "-m", "--manufacturer", type=str, help="Set manufacturer of the device"
    )
    group_generate.add_argument(
        "-p", "--product_name", type=str, help="Set product name of the device"
    )
    group_generate.add_argument("--vid", type=str, help="Set VID of the device")
    group_generate.add_argument("--pid", type=str, help="Set PID of the device")

    parser_validate = subparsers.add_parser(
        "validate", help="Validate the configuration of a USB device"
    )
    parser_validate.set_defaults(func=validate)

    group_validate = parser_validate.add_mutually_exclusive_group()
    group_validate.add_argument("-i", "--input", type=str, help="Input dictionary")
    group_validate.add_argument("-f", "--file", type=str, help="Input file")

    args = parser.parse_args()
    devices = parse_usb_ids()

    args.func(args)
