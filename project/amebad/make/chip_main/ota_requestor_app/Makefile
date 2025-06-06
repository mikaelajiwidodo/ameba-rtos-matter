#
#    Copyright (c) 2020 Project CHIP Authors
#    All rights reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#
# This is a project Makefile. It is assumed the directory this Makefile resides in is a
# project subdirectory.
#

include $(MAKE_INCLUDE_GEN)

.PHONY: all clean

#*****************************************************************************#
#                              VARIABLES                                      #
#*****************************************************************************#
OUTPUT_DIR = $(CHIPDIR)/examples/ota-requestor-app/ameba/build/chip
CODEGEN_DIR = $(OUTPUT_DIR)/codegen

DIR = $(SRCDIR)
DIR += $(CHIPDIR)/src
DIR += $(CHIPDIR)/src/app
DIR += $(CHIPDIR)/src/app/server
DIR += $(CHIPDIR)/src/lib/dnssd/minimal_mdns/responders
DIR += $(CHIPDIR)/examples/platform/ameba/ota
DIR += $(CHIPDIR)/examples/platform/ameba/route_hook
DIR += $(CHIPDIR)/examples/providers
DIR += $(CHIPDIR)/zzz_generated/app-common/app-common/zap-generated
DIR += $(CHIPDIR)/zzz_generated/app-common/app-common/zap-generated/attributes
DIR += $(CODEGEN_DIR)/app
DIR += $(CODEGEN_DIR)/zap-generated
DIR += $(CHIPDIR)/examples/ota-requestor-app/ota-requestor-common
DIR += $(CHIPDIR)/examples/ota-requestor-app/ameba/main
DIR += $(BASEDIR)/component/common/application/matter/api
DIR += $(BASEDIR)/component/common/application/matter/core

vpath %.cpp $(DIR) $(shell find $(DIR) -type d)
vpath %.c $(DIR) $(shell find $(DIR) -type d)

#*****************************************************************************#
#                              BUILD DEFINITIONS                              #
#*****************************************************************************#

CHIP_ENABLE_AMEBA_TC = $(shell grep '\#define CHIP_ENABLE_AMEBA_TERMS_AND_CONDITION ' $(MATTER_DIR)/common/include/platform_opts_matter.h | tr -s '[:space:]' | cut -d' ' -f3)
CHIP_ENABLE_OTA_REQUESTOR = $(shell grep 'chip_enable_ota_requestor' $(OUTPUT_DIR)/args.gn | cut -d' ' -f3)

#*****************************************************************************#
#                              CFLAGS                                         #
#*****************************************************************************#

GLOBAL_CFLAGS += -DCHIP_PROJECT=1
GLOBAL_CFLAGS += -DSTD_PRINTF=1
GLOBAL_CFLAGS += -DCHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER=\"lib/address_resolve/AddressResolve_DefaultImpl.h\"

# matter blemgr adapter options
ifeq ($(CONFIG_BLE_MATTER_ADAPTER),y)
GLOBAL_CFLAGS += -DCONFIG_MATTER_BLEMGR_ADAPTER=1
endif

#*****************************************************************************#
#                              INCLUDE FILE LIST                              #
#*****************************************************************************#

IFLAGS += -I$(CHIPDIR)/examples/platform/ameba
IFLAGS += -I$(CHIPDIR)/examples/platform/ameba/observer
IFLAGS += -I$(CHIPDIR)/examples/providers
IFLAGS += -I$(CHIPDIR)/src/
IFLAGS += -I$(CHIPDIR)/src/app/
IFLAGS += -I$(CHIPDIR)/src/app/util/
IFLAGS += -I$(CHIPDIR)/src/app/server/
IFLAGS += -I$(CHIPDIR)/src/controller/data_model
IFLAGS += -I$(CHIPDIR)/src/include/
IFLAGS += -I$(CHIPDIR)/src/lib/
IFLAGS += -I$(CHIPDIR)/third_party/nlassert/repo/include/
IFLAGS += -I$(CHIPDIR)/third_party/nlio/repo/include/
IFLAGS += -I$(CHIPDIR)/third_party/nlunit-test/repo/src
IFLAGS += -I$(CHIPDIR)/zzz_generated
IFLAGS += -I$(CHIPDIR)/zzz_generated/app-common
IFLAGS += -I$(CODEGEN_DIR)
IFLAGS += -I$(CODEGEN_DIR)/zap-generated
IFLAGS += -I$(CHIPDIR)/examples/all-clusters-app/ameba/main/include #to get AmebaObserver.h
IFLAGS += -I$(CHIPDIR)/examples/ota-requestor-app/ota-requestor-common
IFLAGS += -I$(CHIPDIR)/examples/ota-requestor-app/ota-requestor-common/include
IFLAGS += -I$(CHIPDIR)/examples/ota-requestor-app/ameba/main/include
IFLAGS += -I$(CHIPDIR)/examples/ota-requestor-app/ameba/build/chip/gen/include

#*****************************************************************************#
#                              SOURCE FILE LIST                               #
#*****************************************************************************#

CSRC += $(CHIPDIR)/examples/platform/ameba/route_hook/ameba_route_hook.c
CSRC += $(CHIPDIR)/examples/platform/ameba/route_hook/ameba_route_table.c

CPPSRC += $(CHIPDIR)/examples/providers/DeviceInfoProviderImpl.cpp

CPPSRC += $(CHIPDIR)/src/app/SafeAttributePersistenceProvider.cpp
CPPSRC += $(CHIPDIR)/src/app/StorageDelegateWrapper.cpp
CPPSRC += $(CHIPDIR)/src/app/icd/server/ICDMonitoringTable.cpp
CPPSRC += $(CHIPDIR)/src/app/server/AclStorage.cpp
CPPSRC += $(CHIPDIR)/src/app/server/DefaultAclStorage.cpp
CPPSRC += $(CHIPDIR)/src/app/server/EchoHandler.cpp
CPPSRC += $(CHIPDIR)/src/app/server/Dnssd.cpp
CPPSRC += $(CHIPDIR)/src/app/server/Server.cpp
CPPSRC += $(CHIPDIR)/src/app/server/CommissioningWindowManager.cpp

CPPSRC += $(CHIPDIR)/src/app/util/attribute-storage.cpp
CPPSRC += $(CHIPDIR)/src/app/util/attribute-table.cpp
CPPSRC += $(CHIPDIR)/src/app/util/binding-table.cpp
CPPSRC += $(CHIPDIR)/src/app/util/DataModelHandler.cpp
CPPSRC += $(CHIPDIR)/src/app/util/ember-io-storage.cpp
CPPSRC += $(CHIPDIR)/src/app/util/generic-callback-stubs.cpp
CPPSRC += $(CHIPDIR)/src/app/util/util.cpp
CPPSRC += $(CHIPDIR)/src/app/util/privilege-storage.cpp
CPPSRC += $(CHIPDIR)/src/app/util/persistence/AttributePersistenceProvider.cpp
CPPSRC += $(CHIPDIR)/src/app/util/persistence/DefaultAttributePersistenceProvider.cpp

CPPSRC += $(CHIPDIR)/src/app/reporting/Engine.cpp
CPPSRC += $(CHIPDIR)/src/app/reporting/reporting.cpp

ifeq ($(CHIP_ENABLE_AMEBA_TC), 1)
CPPSRC += $(CHIPDIR)/src/app/server/DefaultTermsAndConditionsProvider.cpp
CPPSRC += $(CHIPDIR)/src/app/server/TermsAndConditionsManager.cpp
endif

CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/CodegenDataModelProvider.cpp
CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/CodegenDataModelProvider_Read.cpp
CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/CodegenDataModelProvider_Write.cpp
CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/EmberAttributeDataBuffer.cpp
CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/EmberMetadata.cpp
CPPSRC += $(CHIPDIR)/src/data-model-providers/codegen/Instance.cpp

CPPSRC += $(CHIPDIR)/src/setup_payload/OnboardingCodesUtil.cpp

CPPSRC += $(CHIPDIR)/zzz_generated/app-common/app-common/zap-generated/attributes/Accessors.cpp
CPPSRC += $(CHIPDIR)/zzz_generated/app-common/app-common/zap-generated/cluster-objects.cpp

CPPSRC += $(shell cat $(CODEGEN_DIR)/cluster-file.txt)
CPPSRC += $(CODEGEN_DIR)/app/callback-stub.cpp
CPPSRC += $(CODEGEN_DIR)/app/cluster-init-callback.cpp
CPPSRC += $(CODEGEN_DIR)/zap-generated/IMClusterCommandHandler.cpp

CPPSRC += $(CHIPDIR)/examples/ota-requestor-app/ameba/main/chipinterface.cpp
CPPSRC += $(CHIPDIR)/examples/ota-requestor-app/ameba/main/DeviceCallbacks.cpp
CPPSRC += $(CHIPDIR)/examples/ota-requestor-app/ameba/main/CHIPDeviceManager.cpp
CPPSRC += $(CHIPDIR)/examples/ota-requestor-app/ameba/main/Globals.cpp
CPPSRC += $(CHIPDIR)/examples/ota-requestor-app/ameba/main/LEDWidget.cpp

ifeq ($(CHIP_ENABLE_OTA_REQUESTOR), true)
CPPSRC += $(CHIPDIR)/examples/platform/ameba/ota/OTAInitializer.cpp
endif

CPPSRC += $(BASEDIR)/component/common/application/matter/api/matter_api.cpp
CPPSRC += $(BASEDIR)/component/common/application/matter/core/matter_device_utils.cpp

#*****************************************************************************#
#                              OBJECT FILE LIST                               #
#*****************************************************************************#
CPPOBJS = $(notdir $(CPPSRC:.cpp=.o))
COBJS = $(notdir $(CSRC:.c=.o))
OBJS = $(CPPOBJS)
OBJS += $(COBJS)
STATIC_LIB = lib_main.a

#*****************************************************************************#
#                              INCLUDE DEPENDENCY                             #
#*****************************************************************************#
-include $(OBJS:.o=.d)

#*****************************************************************************#
#                              RULES TO GENERATE TARGETS                      #
#*****************************************************************************#
all: CORE_TARGETS

#*****************************************************************************#
#                              GENERATE OBJECT FILE                           #
#*****************************************************************************#
CORE_TARGETS: $(OBJS) $(STATIC_LIB)
$(STATIC_LIB):$(OBJS)
	$(AR) rvs $@ $^
	$(MOVE) -f $@ $(ROOTDIR)/lib/application

#*****************************************************************************#
#                              CLEAN GENERATED FILES                          #
#*****************************************************************************#
clean:
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.o
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.i
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.s
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.d
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.ii
	rm -f $(MATTER_BUILDDIR)/make/chip_main/ota_requestor_app/*.su

-include $(DEPS)
