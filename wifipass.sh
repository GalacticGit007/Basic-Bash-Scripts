#!/bin/bash

for file in /etc/NetworkManager/system-connections/*; do
    ssid=$(sudo grep "^ssid=" "$file" | cut -d'=' -f2)
    pass=$(sudo grep "^psk=" "$file" | cut -d'=' -f2)
    echo "SSID: $ssid"
    echo "Password: $pass"
    echo "--------------------------------"
done

