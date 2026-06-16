# SPDX-License-Identifier: GPL-2.0-only

ifeq ($(SUBTARGET),msm8916)

define Build/generate-squashfs-gpt
  chmod +x $(TOPDIR)/target/linux/$(BOARD)/image/generate_squashfs_gpt.sh
  $(TOPDIR)/target/linux/$(BOARD)/image/generate_squashfs_gpt.sh $@
endef

define Build/install-flasher
  $(CP) $(TOPDIR)/target/linux/$(BOARD)/image/flash.sh $@
  chmod +x $@
endef

define Build/generate-firmware
  chmod +x $(TOPDIR)/target/linux/$(BOARD)/image/generate_firmware.sh
  $(TOPDIR)/target/linux/$(BOARD)/image/generate_firmware.sh $@
endef

define Build/copy-kernel-to-rootfs
	mkdir -p "$(TARGET_DIR)/boot"

	KERNEL_BIN="$$(find "$(KDIR)" -maxdepth 1 -type f -name '*-kernel.bin' | head -n 1)"; \
	[ -n "$$KERNEL_BIN" ] || { echo "Kernel image not found in $(KDIR)"; exit 1; }; \
	cp "$$KERNEL_BIN" "$(TARGET_DIR)/boot/Image.gz"; \
	cp "$(KDIR)/image-$(DEVICE_DTS).dtb" "$(TARGET_DIR)/boot/$(DEVICE_DTS).dtb"; \
	mkdir -p "$(TARGET_DIR)/boot/extlinux"; \
	{ \
		echo 'DEFAULT openwrt'; \
		echo 'TIMEOUT 3'; \
		echo ''; \
		echo 'LABEL openwrt'; \
		echo '    KERNEL /boot/Image.gz'; \
		echo '    FDT /boot/$(DEVICE_DTS).dtb'; \
		echo '    APPEND console=ttyMSM0,115200 root=/dev/mmcblk0p25 rootfstype=squashfs rootwait'; \
	} > "$(TARGET_DIR)/boot/extlinux/extlinux.conf"
endef

define Device/msm8916
  SOC := msm8916

  CMDLINE := "earlycon console=tty0 console=ttyMSM0,115200 root=/dev/mmcblk0p25 rootfstype=squashfs rootwait"

  FEATURES := squashfs

  IMAGE/system.img := copy-kernel-to-rootfs | append-rootfs | append-metadata

  ARTIFACTS := squashfs-gpt_both0.bin flash.sh firmware.zip

  ARTIFACT/squashfs-gpt_both0.bin := generate-squashfs-gpt
  ARTIFACT/flash.sh := install-flasher
  ARTIFACT/firmware.zip := generate-firmware
endef

define Device/yiming-uz801v3
  $(Device/msm8916)
  DEVICE_VENDOR := YiMing
  DEVICE_MODEL := uz801v3
  FILESYSTEMS := squashfs
  DEVICE_PACKAGES := wpad-basic-wolfssl rmtfs uci-usb-gadget \
                     block-mount f2fs-tools \
                     msm-firmware-dumper
endef
TARGET_DEVICES += yiming-uz801v3

define Device/generic-uf02
  $(Device/msm8916)
  DEVICE_VENDOR := Generic
  DEVICE_MODEL := UF02 (250605 V0S)
  FILESYSTEMS := squashfs
  DEVICE_PACKAGES := wpad-basic-wolfssl rmtfs uci-usb-gadget \
                     block-mount f2fs-tools \
                     msm-firmware-dumper
endef
TARGET_DEVICES += generic-uf02

define Device/samsung-j500g
  $(Device/msm8916)
  DEVICE_VENDOR := Samsung
  DEVICE_MODEL := Galaxy J5 2015 (J500G)
  FILESYSTEMS := squashfs
  DEVICE_DTS := msm8916-samsung-j5
  SUPPORTED_DEVICES += samsung,j5lte
  DEVICE_PACKAGES := wpad-basic-wolfssl rmtfs uci-usb-gadget \
                     block-mount f2fs-tools \
                     msm-firmware-dumper
endef
TARGET_DEVICES += samsung-j500g

endif
