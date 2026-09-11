//
// Copyright (C) 2026 The Team Win Recovery Project
//
// SPDX-License-Identifier: Apache-2.0
//

#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <hardware/boot_control.h>
#include <hardware/hardware.h>

#include "bcblib.h"

#define ARRAY_SIZE(a)	(sizeof(a) / sizeof((a)[0]))

static const char *bcb_paths[] = {
	"/dev/block/platform/bootdevice/by-name/misc",
	"/dev/block/platform/mtk-msdc.0/by-name/misc",
	"/dev/block/bootdevice/by-name/misc",
	"/dev/disk/by-partlabel/misc",
};

static const char *slot_suffixes[BCB_MAX_SLOTS] = { "_a", "_b" };

static int bcb_open(int flags)
{
	unsigned int i;
	int fd;

	for (i = 0; i < ARRAY_SIZE(bcb_paths); i++) {
		fd = open(bcb_paths[i], flags);
		if (fd >= 0)
			return fd;
	}

	return -ENOENT;
}

static int bcb_read(struct bcb *bcb)
{
	int fd = bcb_open(O_RDONLY);
	ssize_t ret;

	if (fd < 0)
		return fd;

	ret = pread(fd, bcb, sizeof(*bcb), BCB_OFFSET);
	close(fd);

	if (ret != (ssize_t)sizeof(*bcb))
		return -EIO;

	if (!bcblib_bcb_magic_valid(bcb))
		return -EINVAL;

	return 0;
}

static int bcb_write(const struct bcb *bcb)
{
	int fd = bcb_open(O_WRONLY);
	ssize_t ret;

	if (fd < 0)
		return fd;

	ret = pwrite(fd, bcb, sizeof(*bcb), BCB_OFFSET);
	if (ret == (ssize_t)sizeof(*bcb))
		fsync(fd);
	close(fd);

	return ret == (ssize_t)sizeof(*bcb) ? 0 : -EIO;
}

static int slot_from_cmdline(void)
{
	char buf[2048];
	char *p;
	FILE *fp;
	size_t len;

	fp = fopen("/proc/cmdline", "r");
	if (!fp)
		return -ENOENT;

	len = fread(buf, 1, sizeof(buf) - 1, fp);
	fclose(fp);
	buf[len] = '\0';

	p = strstr(buf, "androidboot.slot_suffix=");
	if (!p)
		return -ENOENT;

	p += strlen("androidboot.slot_suffix=");

	if (!strncmp(p, "_a", 2))
		return 0;
	if (!strncmp(p, "_b", 2))
		return 1;

	return -EINVAL;
}

static bool slot_is_bootable(const struct bcb *bcb, unsigned slot)
{
	return bcblib_metadata_get_success(&bcb->slot[slot]) ||
	       bcblib_metadata_get_tries(&bcb->slot[slot]) > 0;
}

static void bootctrl_init(boot_control_module_t *module __unused)
{
}

static unsigned bootctrl_get_number_slots(boot_control_module_t *module __unused)
{
	return BCB_MAX_SLOTS;
}

static unsigned bootctrl_get_current_slot(boot_control_module_t *module __unused)
{
	struct bcb bcb;
	int slot;

	if (bcb_read(&bcb) == 0) {
		slot = bcblib_bcb_get_active_slot(&bcb, false, false);
		if (slot >= 0)
			return (unsigned)slot;
	}

	slot = slot_from_cmdline();

	return slot >= 0 ? (unsigned)slot : 0;
}

static int bootctrl_mark_boot_successful(boot_control_module_t *module)
{
	struct bcb bcb;
	int ret;

	ret = bcb_read(&bcb);
	if (ret)
		return ret;

	bcblib_metadata_set_success(&bcb.slot[bootctrl_get_current_slot(module)],
				    true);

	return bcb_write(&bcb);
}

static int bootctrl_set_active_boot_slot(boot_control_module_t *module __unused,
					 unsigned slot)
{
	struct bcb bcb;
	int ret;

	if (slot >= BCB_MAX_SLOTS)
		return -EINVAL;

	ret = bcb_read(&bcb);
	if (ret)
		return ret;

	bcb.slot[slot] = BCB_SLOT_METADATA_ACTIVE;
	bcb.slot[!slot] = BCB_SLOT_METADATA_EMPTY;

	return bcb_write(&bcb);
}

static int bootctrl_set_slot_as_unbootable(boot_control_module_t *module __unused,
					   unsigned slot)
{
	struct bcb bcb;
	int ret;

	if (slot >= BCB_MAX_SLOTS)
		return -EINVAL;

	ret = bcb_read(&bcb);
	if (ret)
		return ret;

	if (!slot_is_bootable(&bcb, !slot))
		return -EINVAL;

	bcb.slot[slot] = BCB_SLOT_METADATA_EMPTY;

	return bcb_write(&bcb);
}

static int bootctrl_is_slot_bootable(boot_control_module_t *module __unused,
				     unsigned slot)
{
	struct bcb bcb;
	int ret;

	if (slot >= BCB_MAX_SLOTS)
		return -EINVAL;

	ret = bcb_read(&bcb);
	if (ret)
		return ret;

	return slot_is_bootable(&bcb, slot) ? 1 : 0;
}

static int bootctrl_is_slot_marked_successful(boot_control_module_t *module __unused,
					      unsigned slot)
{
	struct bcb bcb;
	int ret;

	if (slot >= BCB_MAX_SLOTS)
		return -EINVAL;

	ret = bcb_read(&bcb);
	if (ret)
		return ret;

	return bcblib_metadata_get_success(&bcb.slot[slot]) ? 1 : 0;
}

static const char *bootctrl_get_suffix(boot_control_module_t *module __unused,
				       unsigned slot)
{
	if (slot >= BCB_MAX_SLOTS)
		return NULL;

	return slot_suffixes[slot];
}

static struct hw_module_methods_t bootctrl_methods = {
	.open = NULL,
};

boot_control_module_t HAL_MODULE_INFO_SYM = {
	.common = {
		.tag			= HARDWARE_MODULE_TAG,
		.module_api_version	= BOOT_CONTROL_MODULE_API_VERSION_0_1,
		.hal_api_version	= HARDWARE_HAL_API_VERSION,
		.id			= BOOT_CONTROL_HARDWARE_MODULE_ID,
		.name			= "Amazon BCB boot control HAL",
		.author			= "The Team Win Recovery Project",
		.methods		= &bootctrl_methods,
	},
	.init			= bootctrl_init,
	.getNumberSlots		= bootctrl_get_number_slots,
	.getCurrentSlot		= bootctrl_get_current_slot,
	.markBootSuccessful	= bootctrl_mark_boot_successful,
	.setActiveBootSlot	= bootctrl_set_active_boot_slot,
	.setSlotAsUnbootable	= bootctrl_set_slot_as_unbootable,
	.isSlotBootable		= bootctrl_is_slot_bootable,
	.getSuffix		= bootctrl_get_suffix,
	.isSlotMarkedSuccessful	= bootctrl_is_slot_marked_successful,
};
