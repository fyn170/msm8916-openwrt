# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk


define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Devices ###
define Device/Default
	PROFILES := Default

	KERNEL = kernel-bin | gzip | append-dtb

	IMAGES := system.img

	IMAGE/system.img := append-rootfs | append-metadata

	DEVICE_DTS_DIR := $(DTS_DIR)/qcom
	DEVICE_DTS = $$(SOC)-$(lastword $(subst _, ,$(1)))

	CMDLINE := "earlycon console=ttyMSM0,115200 rw"
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
