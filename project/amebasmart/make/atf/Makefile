#
# Copyright (c) 2015-2020, ARM Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

include $(MATTER_BUILDDIR)/make/atf/mbedtls_secure/Makefile

# Add BL32_SOURCES for Matter Secure
BL32_SOURCES +=${MBEDTLS_SOURCES} \
               ${MATTER_DIR}/common/atf/libc/rand.c

# Add WARNINGS for Matter Secure
WARNINGS_TEMP := ${WARNINGS} -Wno-maybe-uninitialized -Wno-unused-variable -Wno-unused-label
WARNINGS      := $(filter-out -Wmaybe-uninitialized, ${WARNINGS_TEMP})

# Add DEFINITIONS for Matter Secure
CONFIG_BUILD_SECURE_TFA	:= 1
CONFIG_MATTER_SECURE    := 1
$(eval $(call add_define,CONFIG_BUILD_SECURE_TFA))
$(eval $(call add_define,CONFIG_MATTER_SECURE))

# Add INCLUDES for Matter Secure
INCLUDES += -I$(MATTER_DIR)/common/port \
            -I$(MATTER_DIR)/common/atf/include
