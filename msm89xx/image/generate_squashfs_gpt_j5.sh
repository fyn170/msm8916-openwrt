#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
#
# Generate GPT image for Samsung Galaxy J5 (SM-J500G) preserving original partition layout.
# This script PRESERVES all original partitions (p1-p27) and only updates:
#   - p26 (boot) with OpenWrt kernel
#   - p28 (rootfs/rootfs_data) with OpenWrt rootfs
#
# Device partition layout (from /proc/partitions):
#   p1-p25:   Original modem/firmware/system partitions (PRESERVED)
#   p26:      Cache 204800 blocks (100 MB) -> Used for boot
#   p27:      Persist 71680 blocks (35 MB) (PRESERVED)
#   p28:      Userdata 5031916 blocks (~2.4 GB) -> rootfs + rootfs_data

set -e

OUTFILE=${1:-gpt_both0.bin}
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
IMG="${TMPDIR}/gpt.img"

# Total size in 512B sectors
TOT_SECTORS=7569408

# GPT boundaries
FIRST_LBA=34
LAST_LBA=$((TOT_SECTORS - 34))

# Partition table for Samsung Galaxy J5 based on /proc/partitions
# All sizes in sectors (512B each)

# p1-p25: Preserve original positions and sizes
P1_START=2048
P1_SIZE=7680
P2_START=$((P1_START + P1_SIZE))
P2_SIZE=29408
P3_START=$((P2_START + P2_SIZE))
P3_SIZE=256
P4_START=$((P3_START + P3_SIZE))
P4_SIZE=16
P5_START=$((P4_START + P4_SIZE))
P5_SIZE=1024
P6_START=$((P5_START + P5_SIZE))
P6_SIZE=256
P7_START=$((P6_START + P6_SIZE))
P7_SIZE=256
P8_START=$((P7_START + P7_SIZE))
P8_SIZE=256
P9_START=$((P8_START + P8_SIZE))
P9_SIZE=1536
P10_START=$((P9_START + P9_SIZE))
P10_SIZE=8
P11_START=$((P10_START + P10_SIZE))
P11_SIZE=5384
P12_START=$((P11_START + P11_SIZE))
P12_SIZE=5120
P13_START=$((P12_START + P12_SIZE))
P13_SIZE=7168
P14_START=$((P13_START + P13_SIZE))
P14_SIZE=1536
P15_START=$((P14_START + P14_SIZE))
P15_SIZE=1536
P16_START=$((P15_START + P15_SIZE))
P16_SIZE=6656
P17_START=$((P16_START + P16_SIZE))
P17_SIZE=7680
P18_START=$((P17_START + P17_SIZE))
P18_SIZE=6400
P19_START=$((P18_START + P18_SIZE))
P19_SIZE=3580
P20_START=$((P19_START + P19_SIZE))
P20_SIZE=1536
P21_START=$((P20_START + P20_SIZE))
P21_SIZE=4
P22_START=$((P21_START + P21_SIZE))
P22_SIZE=4096
P23_START=$((P22_START + P22_SIZE))
P23_SIZE=256
P24_START=$((P23_START + P23_SIZE))
P24_SIZE=4608
P25_START=$((P24_START + P24_SIZE))
P25_SIZE=1064960

# p26: Boot (cache partition, 100 MB = 204800 sectors)
P26_START=$((P25_START + P25_SIZE))
P26_SIZE=204800

# p27: Persist (preserve, 35 MB = 71680 sectors)
P27_START=$((P26_START + P26_SIZE))
P27_SIZE=71680

# p28: Rootfs + rootfs_data (remaining space)
P28_START=$((P27_START + P27_SIZE))
P28_SIZE=$((LAST_LBA - P28_START + 1))

[ ${P28_SIZE} -gt 0 ] || { echo "ERROR: No space for rootfs"; exit 1; }

truncate -s $((TOT_SECTORS * 512)) "${IMG}"

sfdisk "${IMG}" <<EOF
label: gpt
label-id: DB708ACF-2E04-8DE2-BAFE-30C9B26444C5
unit: sectors
first-lba: ${FIRST_LBA}
last-lba: ${LAST_LBA}
sector-size: 512

gpt.img1   : start=${P1_START}, size=${P1_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p1"
gpt.img2   : start=${P2_START}, size=${P2_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p2"
gpt.img3   : start=${P3_START}, size=${P3_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p3"
gpt.img4   : start=${P4_START}, size=${P4_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p4"
gpt.img5   : start=${P5_START}, size=${P5_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p5"
gpt.img6   : start=${P6_START}, size=${P6_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p6"
gpt.img7   : start=${P7_START}, size=${P7_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p7"
gpt.img8   : start=${P8_START}, size=${P8_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p8"
gpt.img9   : start=${P9_START}, size=${P9_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p9"
gpt.img10  : start=${P10_START}, size=${P10_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p10"
gpt.img11  : start=${P11_START}, size=${P11_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p11"
gpt.img12  : start=${P12_START}, size=${P12_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p12"
gpt.img13  : start=${P13_START}, size=${P13_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p13"
gpt.img14  : start=${P14_START}, size=${P14_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p14"
gpt.img15  : start=${P15_START}, size=${P15_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p15"
gpt.img16  : start=${P16_START}, size=${P16_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p16"
gpt.img17  : start=${P17_START}, size=${P17_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p17"
gpt.img18  : start=${P18_START}, size=${P18_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p18"
gpt.img19  : start=${P19_START}, size=${P19_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p19"
gpt.img20  : start=${P20_START}, size=${P20_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p20"
gpt.img21  : start=${P21_START}, size=${P21_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p21"
gpt.img22  : start=${P22_START}, size=${P22_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p22"
gpt.img23  : start=${P23_START}, size=${P23_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p23"
gpt.img24  : start=${P24_START}, size=${P24_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p24"
gpt.img25  : start=${P25_START}, size=${P25_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="p25"
gpt.img26  : start=${P26_START}, size=${P26_SIZE}, type=20117F86-E985-4357-B9EE-374BC1D8487D, name="boot"
gpt.img27  : start=${P27_START}, size=${P27_SIZE}, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, name="persist"
gpt.img28  : start=${P28_START}, size=${P28_SIZE}, type=1B81E7E6-F50D-419B-A739-2AEEF8DA3335, name="rootfs"
EOF

# Assemble gpt_both0.bin: primary header+entries + backup header
dd if="${IMG}" of="${OUTFILE}" bs=512 count=34
dd if="${IMG}" bs=512 skip=2 count=32 >> "${OUTFILE}"
dd if="${IMG}" bs=512 skip=$((TOT_SECTORS - 1)) count=1 >> "${OUTFILE}"

echo "Generated J5-specific GPT: ${OUTFILE}"
echo "Preserved partitions: p1-p27"
echo "Updated partitions: p26 (boot: 100 MB), p28 (rootfs: ~2.4 GB)"
