#!/bin/bash

# Target number of cores requested (passed from keybinding)
TARGET=$1
# Get the total number of cores physically available on the system
TOTAL_AVAILABLE=$(nproc --all)

# Validation: If no number is provided or it's less than 1, default to 1
if [[ -z "$TARGET" || "$TARGET" -lt 1 ]]; then
    TARGET=1
fi

# If "0" or a high number is passed, use all available cores
if [[ "$TARGET" -ge "$TOTAL_AVAILABLE" || "$TARGET" -eq 0 ]]; then
    TARGET=$TOTAL_AVAILABLE
fi

# Core 0 is always online. We loop through the rest.
# cpu1 corresponds to the 2nd core, etc.
for ((i=1; i<TOTAL_AVAILABLE; i++)); do
    if [[ $i -lt $TARGET ]]; then
        # Turn core ON
        echo 1 > "/sys/devices/system/cpu/cpu$i/online" 2>/dev/null
    else
        # Turn core OFF
        echo 0 > "/sys/devices/system/cpu/cpu$i/online" 2>/dev/null
    fi
done

# Send a notification to the desktop (requires libnotify / notify-send)
notify-send "CPU Manager" "Active Cores: $(nproc) / $TOTAL_AVAILABLE" -t 2000 -i processor
