# Samsung Galaxy J5 (SM-J500G) Flashing Guide

## Overview

This guide explains how to flash OpenWrt to a Samsung Galaxy J5 using the **preserve radio** approach. This method keeps all original modem/radio partitions intact and only replaces the kernel and rootfs.

## Device Partitioning

Original J5 partition layout (from `/proc/partitions`):

| Partition | Size | Purpose | Action |
|-----------|------|---------|--------|
| p1-p25 | ~2 GB | Radio/modem/system/firmware | **PRESERVE** |
| p26 | 100 MB | Cache → Boot | **REPLACE** with OpenWrt kernel |
| p27 | 35 MB | Persist | **PRESERVE** |
| p28 | ~2.4 GB | Userdata → Rootfs | **REPLACE** with OpenWrt rootfs |

## Build Artifacts

When building for J5 (`diffconfig_j500g`), you'll get:

```
bin/targets/msm89xx/msm8916/
├── openwrt-msm89xx-msm8916-samsung-j500g-squashfs-boot.img
├── openwrt-msm89xx-msm8916-samsung-j500g-squashfs-gpt_both0.bin  (J5-specific GPT)
├── openwrt-msm89xx-msm8916-samsung-j500g-squashfs-system.img
├── openwrt-msm89xx-msm8916-samsung-j500g-flash.sh              (J5-specific flash script)
└── openwrt-msm89xx-msm8916-samsung-j500g-firmware.zip
```

## Prerequisites

1. **EDL tool**: https://github.com/bkerler/edl
   ```bash
   pip install edl
   ```

2. **Device in EDL mode**: Follow your device's EDL entry method

3. **Backup**: It's recommended to backup radio partitions first

## Flashing Steps

### 1. Enter EDL Mode

Refer to your device's specific method (usually bootloader key + cable).

### 2. Verify EDL Connection

```bash
edl printgpt
```

Should show device info and current partition table.

### 3. Flash OpenWrt

Navigate to the build output directory:

```bash
cd bin/targets/msm89xx/msm8916/
./openwrt-msm89xx-msm8916-samsung-j500g-flash.sh
```

The script will:
1. Detect OpenWrt images (GPT, kernel, rootfs, firmware)
2. Backup critical radio partitions (fsc, fsg, modemst1/2, modem, persist, sec)
3. Flash custom GPT (preserving p1-p27)
4. Flash firmware (aboot, hyp, rpm, sbl1, tz)
5. Flash kernel to p26
6. Flash rootfs to p28
7. Restore backed-up radio partitions
8. Reboot device

### 4. Wait for Boot

The device should reboot and boot into OpenWrt. Watch for:
- Serial output (if available)
- LED indicators
- Network availability (USB gadget, WiFi, cellular)

## Troubleshooting

### Device not booting

1. **Check serial output** (if UART cable available)
2. **Verify firmware compatibility** - Ensure lk1st firmware was built correctly with Samsung-specific compatible string
3. **Check partition offset** - Verify boot kernel is at p26 and rootfs at p28

### USB not detected on PC

1. Device may still be booting. Wait 30-60 seconds.
2. Check `CONFIG_KMOD_USB_GADGET` is enabled in `.config`
3. Verify modem/radio partitions were preserved (they provide essential drivers)

### Modem not working

Radio partitions (p1-p25, p27) should be preserved. If modem still doesn't work:
1. Extract MCFG from original firmware
2. Copy to `/lib/firmware/MCFG_SW.MBN` on device

## Safe Recovery

If something goes wrong, you can restore original firmware:

1. Boot back to EDL
2. Flash original Samsung firmware (separate from OpenWrt)
3. Radio partitions are backed up in `saved/` directory during flash

## Script Details

### `generate_squashfs_gpt_j5.sh`

Generates GPT with:
- Preserved p1-p27 sector offsets (matches original)
- Updated p26: Boot partition (100 MB)
- Updated p28: Rootfs partition (rest of device)

### `flash_j5.sh`

Flashing procedure:
1. Backs up radio partitions before modifying GPT
2. Flashes GPT with preserved layout
3. Flashes firmware binaries
4. Flashes kernel and rootfs to correct partitions
5. Restores backed-up radio partitions

## References

- PostmarketOS Samsung J5 guide
- EDL documentation: https://github.com/bkerler/edl
- OpenWrt MSM8916 project: https://github.com/hkfuertes/msm8916-openwrt
