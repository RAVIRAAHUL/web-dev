#!/bin/bash
# zeroTraceRunner.sh
# ZeroTrace Live ISO entrypoint menu

BIN="/usr/local/bin/a.out"

# Sanity check for binary
if [[ ! -x "$BIN" ]]; then
    echo "❌ Error: $BIN not found or not executable at $BIN"
    exit 1
fi

# === Failsafe window ===
echo "ZeroTrace will start in 5 seconds..."
echo "Press CTRL+C now to cancel and drop to shell."
sleep 5

while true; do
    clear
    echo "=== ZeroTrace Disk Wiper ==="
    echo "Available Disks:"
    disks=( $(lsblk -d -o NAME | grep -v NAME) )
    if [[ ${#disks[@]} -eq 0 ]]; then
        echo "❌ No disks detected."
        read -p "Press Enter to retry or type 'exit zt' to shutdown: " choice
        [[ "$choice" == "exit zt" ]] && shutdown now
        continue
    fi

    for i in "${!disks[@]}"; do
        size=$(lsblk -dn -o SIZE "/dev/${disks[$i]}")
        model=$(lsblk -dn -o MODEL "/dev/${disks[$i]}")
        echo "[$i] /dev/${disks[$i]} — $size — $model"
    done
    echo "============================"
    echo "Type the disk index to erase, or 'exit zt' to shutdown."
    
    read -p "> " choice

    # Shutdown request
    if [[ "$choice" == "exit zt" ]]; then
        echo "⚠️  Shutdown requested..."
        shutdown now
        exit 0
    fi

    # Numeric selection
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -lt ${#disks[@]} ]]; then
        disk="/dev/${disks[$choice]}"
        echo "⚠️ You selected: $disk"
        read -p "Type YES to confirm erasing $disk: " confirm
        if [[ "$confirm" == "YES" ]]; then
            logfile="/var/log/zerotrace-$(date +%Y%m%d-%H%M%S)-${disks[$choice]}.log"
            echo "Running: $BIN $disk --verify"
            $BIN "$disk" --verify 2>&1 | tee "$logfile"
            echo "✅ Wipe complete. Log saved to $logfile"
        else
            echo "Cancelled."
        fi
    else
        echo "❌ Invalid choice."
    fi

    echo
    read -p "Press Enter to continue or type 'exit zt' to shutdown: " again
    [[ "$again" == "exit zt" ]] && shutdown now
done
