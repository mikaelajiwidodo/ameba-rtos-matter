#
# Copyright (c) 2015-2020, ARM Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

#
# Copyright (c) 2015-2020, ARM Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

MATTER_MBEDTLSDIR = $(MATTER_DIR)/common/mbedtls
ifeq ($(MBEDTLS_MATTER_V_2_28_1_ENABLE), y)
MBEDTLS_DIR       = $(MATTER_DIR)/common/mbedtls/mbedtls-2.28.1
else ifeq ($(MBEDTLS_MATTER_V_3_6_1_ENABLE), y)
MBEDTLS_DIR       = $(MATTER_DIR)/common/mbedtls/mbedtls-3.6.1
else ifeq ($(CONFIG_MBEDTLS_V_3_6_2_ENABLE), y)
MBEDTLS_DIR       = $(BASEDIR)/component/ssl/mbedtls-3.6.2
endif

ifneq (${MATTER_SECURE_MBEDTLS_MK},1)
MATTER_SECURE_MBEDTLS_MK := 1

# MBEDTLS_DIR must be set to the mbed TLS main directory (it must contain
# the 'include' and 'library' subdirectories).
ifeq (${MBEDTLS_DIR},)
  $(error Error: MBEDTLS_DIR not set)
endif

MBEDTLS_INC = -I${MATTER_MBEDTLSDIR} \
              -I${MBEDTLS_DIR}/include \
              -I${MBEDTLS_DIR}/include/mbedtls \
              -I${MBEDTLS_DIR}/library \
              -I${MATTER_DIR}/common/os \
              -I${MATTER_DIR}/common/port \
              -I${BASEDIR}/component/ssl/mbedtls_ram_map/rom

# Specify mbed TLS configuration file
MBEDTLS_CONFIG_FILE	:=	"<matter_mbedtls_config.h>"
$(eval $(call add_define,MBEDTLS_CONFIG_FILE))

MBEDTLS_SOURCES += ${MATTER_DIR}/common/atf/mbedtls_secure/mbedtls_secure.c

# LIBMBEDTLS_SRCS:= $(addprefix ${MBEDTLS_DIR}/library/, \
#                     aes.c \
#                     asn1parse.c \
#                     asn1write.c \
#                     base64.c \
#                     bignum.c \
#                     ccm.c \
#                     cipher.c \
#                     cipher_wrap.c \
#                     constant_time.c \
#                     ctr_drbg.c \
#                     ecdsa.c \
#                     ecp.c \
#                     ecp_curves.c \
#                     md.c \
#                     md5.c \
#                     memory_buffer_alloc.c \
#                     oid.c \
#                     pkparse.c \
#                     pkcs5.c \
#                     pkcs12.c \
#                     pem.c \
#                     pk.c \
#                     pkwrite.c \
#                     pk_wrap.c \
#                     platform.c \
#                     platform_util.c \
#                     rsa.c \
#                     sha1.c \
#                     sha256.c \
#                     sha512.c \
#                     ssl_tls.c \
#                     x509_create.c \
#                     x509write_csr.c \
#                     )

# ifeq ($(MBEDTLS_MATTER_V_2_28_1_ENABLE), y)
# LIBMBEDTLS_SRCS+= $(addprefix ${MBEDTLS_DIR}/library/, \
#                     rsa_internal.c \
#                     )
# else ifeq ($(MBEDTLS_MATTER_V_3_6_1_ENABLE), y)
# LIBMBEDTLS_SRCS+= $(addprefix ${MBEDTLS_DIR}/library/, \
#                     bignum_core.c \
#                     bignum_mod.c \
#                     bignum_mod_raw.c \
#                     rsa_alt_helpers.c \
#                     sha3.c \
#                     )
# else ifeq ($(CONFIG_MBEDTLS_V_3_6_2_ENABLE), y)
# LIBMBEDTLS_SRCS+= $(addprefix ${MBEDTLS_DIR}/library/, \
#                     des.c \
#                     pk_ecc.c \
#                     bignum_core.c \
#                     bignum_mod.c \
#                     bignum_mod_raw.c \
#                     rsa_alt_helpers.c \
#                     sha3.c \
#                     )
# endif

# LIBMBEDTLS_SRCS += ${MATTER_MBEDTLSDIR}/matter_mbedtls_nsc.c

# $(eval $(call MAKE_LIB,mbedtls))

endif


# Add BL32_SOURCES for Matter Secure
BL32_SOURCES += ${MBEDTLS_SOURCES} \
                ${MATTER_DIR}/common/atf/service/matter_rtk_svc_setup.c

# Add WARNINGS for Matter Secure
WARNINGS_TEMP := ${WARNINGS} -Wno-maybe-uninitialized -Wno-unused-variable -Wno-unused-label
WARNINGS      := $(filter-out -Wmaybe-uninitialized, ${WARNINGS_TEMP})

# Add DEFINITIONS for Matter Secure
CONFIG_BUILD_SECURE	       := 1
CONFIG_MATTER_SECURE       := 1
CONFIG_PLATFORM_AMEBASMART := 1
$(eval $(call add_define,CONFIG_BUILD_SECURE))
$(eval $(call add_define,CONFIG_MATTER_SECURE))
$(eval $(call add_define,CONFIG_PLATFORM_AMEBASMART))

# ROM_SYMBOL_ACUT=$(BASEDIR)/amebasmart_gcc_project/project_hp/asdk/ld/rlx8721d_rom_symbol_acut_s.ld

# Add INCLUDES for Matter Secure
INCLUDES += -I${MATTER_DIR}/common/port \
            -I${MATTER_DIR}/common/atf/include

# Provide additional lib to add srand and rand API
# LIBRAND_SRCS = ${MATTER_DIR}/common/atf/libc/rand.c
# $(eval $(call MAKE_LIB,rand))
BL32_LIBS += ${MATTER_DIR}/common/atf/libc/librand.a
# LDLIBS    += ${PROJECT_DIR}/../build/project_ap/asdk/make/image2/lib_matter/atf_mbedtls_secure/lib_atf_mbedtls_secure.a
# amebasmart_gcc_project/project_ap/asdk/lib/application/lib_atf_mbedtls_secure.a
LDLIBS    += ${PROJECT_DIR}/asdk/lib/application/lib_atf_mbedtls_secure.a

