/******************************************************************************
  *
  * This module is a confidential and proprietary property of RealTek and
  * possession or use of this module requires written permission of RealTek.
  *
  * Copyright(c) 2016, Realtek Semiconductor Corporation. All rights reserved.
  *
******************************************************************************/

#include "kv.h"
#include "vfs.h"
#include "ff.h"
#include "littlefs_adapter.h"
#include <ameba_flashcfg.h>
#include <flash_api.h>

extern FILE *fopen(const char *filename, const char *mode);
extern int fclose(FILE *stream);
extern size_t fwrite(const void *ptr, size_t size, size_t count, FILE *stream);
extern size_t fread(void *ptr, size_t size, size_t count, FILE *stream);


#define KV_LIST_LENGTH 1024

static char *kv_matter_prefix;

int rt_kv_deinit(void)
{
	dirent *info;
	DIR *dir;
	char *path = NULL;
	int ret = -1;

	kv_matter_prefix = find_vfs_tag(VFS_REGION_1);
	if (kv_matter_prefix == NULL) {
		goto exit;
	}

	if ((path = rtos_mem_zmalloc(MAX_KEY_LENGTH + 2)) == NULL) {
		VFS_DBG(VFS_ERROR, "KV malloc fail");
		goto exit;
	}

	DiagSnPrintf(path, MAX_KEY_LENGTH + 2, "%s:KV", kv_matter_prefix);

	dir = (DIR *)opendir(path);
	if (dir == NULL) {
		VFS_DBG(VFS_ERROR, "opendir failed");
		goto exit;
	}

	while (1) {
		info = readdir((void **)dir);
		if (info == NULL) {
			break;
		} else if (strcmp(info->d_name, ".") != 0 && strcmp(info->d_name, "..") != 0) {
			ret = rt_kv_delete(info->d_name);
			if (ret < 0)
			{
				DiagPrintf("rt_kv_deinit: failed to delete %s\n", info->d_name);
				goto exit;
			}
			else
			{
				DiagPrintf("rt_kv_deinit: succesfully deleted %s\n", info->d_name);
			}
		}
	}

	ret = closedir((void **)dir);

	exit:
	if (path) {
		rtos_mem_free(path);
	}

	return ret;
}
