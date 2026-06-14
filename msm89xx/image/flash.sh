#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Flash OpenWrt via fastboot (lk2nd).
# Prerequisites: fastboot
# Usage: run from the build output directory (bin/targets/...)

set -euo pipefail

find_image() {
    local dir="$1" pattern="$2" file
    file=$(find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null | head -n 1 || true)
    if [[ -z "${file:-}" ]]; then
        echo "[-] Error: Image not found with pattern: $pattern" >&2
        return 1
    fi
    echo "$file"
}

echo "=== OpenWrt MSM8916 Fastboot Flash Script ==="
echo

echo "[*] Detecting OpenWrt images..."
rootfs_path=$(find_image "." "*-squashfs-system.img") || exit 1

echo "[+] Rootfs: $(basename "$rootfs_path")"

echo
echo "[*] Checking fastboot device..."
fastboot devices | grep -q . || {
    echo "[-] Error: no fastboot device found"
    exit 1
}

echo
read -r -p "Continue with fastboot flashing? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "[!] Cancelled"
    exit 0
fi

echo
echo "=== Flashing partitions (fastboot) ==="

# Rootfs partition name may be "rootfs" or "system" depending on the target.
if fastboot getvar partition-type:rootfs 2>&1 | grep -q "partition-type"; then
    fastboot flash rootfs "$rootfs_path"
elif fastboot getvar partition-type:system 2>&1 | grep -q "partition-type"; then
    fastboot flash system "$rootfs_path"
else
    echo "[-] Error: neither rootfs nor system partition exists in fastboot"
    exit 1
fi

echo
echo "[+] Flash completed successfully"
echo "[*] Rebooting..."
fastboot reboot
