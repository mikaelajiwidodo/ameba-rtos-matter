include $(MAKE_INCLUDE_GEN)

# Include folder list
# -------------------------------------------------------------------

.PHONY: all clean

#*****************************************************************************#
#                               VARIABLES	                              #
#*****************************************************************************#
DIR = $(BASEDIR)/component/application/matter
ATCMDDIR = $(BASEDIR)/component/application/matter/common/atcmd
BTDIR = $(BASEDIR)/component/application/matter/bluetooth/bt_matter_adapter
FSKVDIR = $(BASEDIR)/component/application/matter/file_system/kv
LWIPDIR = $(BASEDIR)/component/application/matter/lwip
MBEDDIR = $(BASEDIR)/component/application/matter/mbedtls
PORTDIR = $(BASEDIR)/component/application/matter/port
PROTOBUFDIR = $(BASEDIR)/component/application/matter/protobuf
NANOPBDIR = $(BASEDIR)/component/application/matter/protobuf/nanopb
CHIPTESTDIR = $(BASEDIR)/component/application/matter/example/chiptest

vpath %.c $(DIR)/ $(shell find $(DIR)/ -type d)

IFLAGS += -I$(MBEDTLSDIR)/library

#*****************************************************************************#
#                               Source FILE LIST                              #
#*****************************************************************************#

# Source file list
# -------------------------------------------------------------------
ifeq ($(CONFIG_MATTER_EN),y)
CSRC += $(ATCMDDIR)/atcmd_matter.c
ifeq ($(CONFIG_BT_MATTER_ADAPTER), y)
CSRC += $(BTDIR)/bt_matter_adapter_app_main.c
CSRC += $(BTDIR)/bt_matter_adapter_app_task.c
CSRC += $(BTDIR)/bt_matter_adapter_peripheral_app.c
CSRC += $(BTDIR)/bt_matter_adapter_service.c
endif
ifeq ($(CONFIG_BLE_MATTER_ADAPTER), y)
CSRC += $(BASEDIR)/component/application/matter/common/bluetooth/matter_blemgr_common.c
CSRC += $(BASEDIR)/component/application/matter/common/bluetooth/ble_matter_adapter_peripheral/ble_matter_adapter_service.c
CSRC += $(BASEDIR)/component/application/matter/common/bluetooth/ble_matter_adapter_peripheral/ble_matter_adapter_peripheral_main.c
endif
CSRC += $(FSKVDIR)/kv_matter.c
CSRC += $(LWIPDIR)/api/lwip_netconf_matter.c
CSRC += $(MBEDDIR)/net_sockets.c
CSRC += $(PORTDIR)/matter_kvs.c
CSRC += $(PORTDIR)/matter_ota.c
CSRC += $(PORTDIR)/matter_timers.c
CSRC += $(PORTDIR)/matter_utils.c
CSRC += $(PORTDIR)/matter_wifis.c
CSRC += $(PORTDIR)/matter_lwip.c
CSRC += $(PROTOBUFDIR)/ameba_factory.pb.c
CSRC += $(NANOPBDIR)/pb_common.c
CSRC += $(NANOPBDIR)/pb_decode.c
CSRC += $(NANOPBDIR)/pb_encode.c
endif

#*****************************************************************************#
#                               Object FILE LIST                              #
#*****************************************************************************#
OBJS = $(notdir $(CSRC:.c=.o))

#*****************************************************************************#
#                               Include Dependency                            #
#*****************************************************************************#
-include $(OBJS:.o=.d)


#*****************************************************************************#
#                        RULES TO GENERATE TARGETS                            #
#*****************************************************************************#
COPY_RAM_OBJS: CORE_TARGETS
all: COPY_RAM_OBJS

#*****************************************************************************#
#              GENERATE OBJECT FILE 
#*****************************************************************************#
CORE_TARGETS: $(OBJS)

#*****************************************************************************#
#                        RULES TO CLEAN TARGETS                               #
#*****************************************************************************#
clean: CLEAN_OBJS
	$(call CLEAN_FUNC)

-include $(DEPS)

