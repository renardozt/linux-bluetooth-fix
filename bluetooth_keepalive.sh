#!/bin/bash

LOG_FILE="$HOME/.bluetooth_reconnect.log"
echo "$(date): Bluetooth keepalive service started (PID: $$)" >> "$LOG_FILE"

start_keepalive() {
    # Don't create if it already exists
    if pactl list short sinks | grep -q "keepalive"; then
        return
    fi

    echo "$(date): Bluetooth is ON -> Loading modules..." >> "$LOG_FILE"
    
    pactl load-module module-null-sink sink_name=keepalive >> "$LOG_FILE" 2>&1
    pactl load-module module-loopback source=keepalive.monitor >> "$LOG_FILE" 2>&1
}

stop_keepalive() {
    # Don't try to remove if it doesn't exist
    if ! pactl list short sinks | grep -q "keepalive"; then
        return
    fi

    echo "$(date): Bluetooth is OFF -> Unloading modules..." >> "$LOG_FILE"

    pactl list short modules | grep "module-loopback" | grep "keepalive.monitor" | awk '{print $1}' | while read -r id; do
        pactl unload-module "$id" >> "$LOG_FILE" 2>&1
    done

    pactl list short modules | grep "module-null-sink" | grep "keepalive" | awk '{print $1}' | while read -r id; do
        pactl unload-module "$id" >> "$LOG_FILE" 2>&1
    done
}

while true; do
    # METHOD: Hardware check via rfkill
    # If the word "Bluetooth" is missing from rfkill output, the hardware is not present.
    if ! rfkill list bluetooth | grep -q "Bluetooth"; then
        # Hardware not found
        # echo "$(date): ERROR - Bluetooth device not found!" >> "$LOG_FILE"
        stop_keepalive
    
    # If "Soft blocked: yes" is present, it's turned off.
    elif rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        # Bluetooth is off
        stop_keepalive
        
    else
        # Bluetooth is ON and UNBLOCKED
        start_keepalive
    fi

    # Wait for 10 seconds before the next check
    sleep 10
done
