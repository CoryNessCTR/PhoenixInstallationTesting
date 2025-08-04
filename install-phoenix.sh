#!/bin/bash

set -e

raspberrypi_identifier="-rpi-"
uname_result=$(uname -a)

current_year=$(date +%Y)

while getopts "y:" flag
do
    case $flag in
        y) current_year=$OPTARG;;
    esac
done

echo "Installing tools for Phoenix installation"
sudo apt-get update
sudo apt-get install -y curl sed

sudo curl -s --compressed -o /usr/share/keyrings/ctr-pubkey.gpg "https://deb.ctr-electronics.com/ctr-pubkey.gpg"
sudo curl -s --compressed -o /etc/apt/sources.list.d/ctr$current_year.list "https://deb.ctr-electronics.com/ctr$current_year.list"

if [ $current_year -lt "2024" ]; then
    echo "ERROR: Year \"$current_year\" is invalid. Check that the system time is correctly set"
    exit 1
fi

if [[ "$uname_result" == *"$raspberrypi_identifier"* ]]; then
    echo "Detected this system is running the raspberry pi OS, updating sources.list to use Raspberry Pi & installing necessary headers."
    sudo sed -i 's/tools stable/tools raspberrypi/g' /etc/apt/sources.list.d/ctr$current_year.list
    sudo apt-get install -y raspberrypi-kernel-headers
else
    echo "Did not detect any special OS on this sytem. Using default sources.list and installing this system's kernel headers."
    sudo apt-get install -y linux-headers-$(uname -r)
fi

echo "Installing Phoenix 6 and CANivore USB"
sudo apt-get update
sudo apt-get install -y canivore-usb-kernel canivore-usb phoenix6
