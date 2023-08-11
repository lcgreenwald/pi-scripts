#!/bin/bash
# Set up rigctld for the Yaesu FT-817/857
# Bluetooth
#rigctld -m 1022 -r /dev/rfcomm0 -s 38400
# USB cable
#rigctld -m 1022 -r /dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_D-if00-port0 -s 38400
#rigctld -m 1022 -r /dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_D-if00-port0 -s 9600
rigctld -m 1022 -r /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_b06b862acbb1eb118516bd7718997a59-if00-port0 -s 38400
#rigctld -m 1022 -r /dev/serial/by-id/usb-Silicon_Labs_CP2102N_USB_to_UART_Bridge_Controller_b06b862acbb1eb118516bd7718997a59-if00-port0 -s 9600

