cmake_minimum_required(VERSION 3.6)

project(light_port)

list(
	APPEND lib_chip_core_inc_path

	${matter_inc_path}

	${CHIPDIR}/config/ameba
	${CHIPDIR}/src
	${CHIPDIR}/src/app
	${CHIPDIR}/src/include
	${CHIPDIR}/src/include/platform/Ameba
	${CHIPDIR}/src/lib
	${CHIPDIR}/src/system
	${CHIPDIR}/third_party/nlassert/repo/include
	${CHIPDIR}/third_party/nlio/repo/include
	${CHIPDIR}/third_party/nlunit-test/repo/src
)

list(
	APPEND lib_chip_main_inc_path

	${matter_inc_path}

	${MATTER_EXAMPLEDIR}/light

	${CHIPDIR}/examples/platform/ameba
	${CHIPDIR}/examples/providers
	${CHIPDIR}/src
	${CHIPDIR}/src/app
	${CHIPDIR}/src/app/util
	${CHIPDIR}/src/app/server
	${CHIPDIR}/src/app/clusters/bindings
	${CHIPDIR}/src/controller/data_model
	${CHIPDIR}/src/include
	${CHIPDIR}/src/lib
	${CHIPDIR}/third_party/nlassert/repo/include
	${CHIPDIR}/third_party/nlio/repo/include
	${CHIPDIR}/third_party/nlunit-test/repo/src
	${CHIPDIR}/zzz_generated/app-common
	${CHIPDIR}/examples/lighting-app/lighting-common
	${CHIPDIR}/examples/lighting-app/ameba/main/include
	${CHIPDIR}/examples/lighting-app/ameba/build/chip/gen/include
	${CODEGENDIR}
)

list(
	APPEND lib_chip_core_flags

	${matter_flags}

	CHIP_PROJECT=1
)

list(
	APPEND lib_chip_main_flags

	${matter_flags}

	CHIP_PROJECT=1
	CHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER=\"lib/address_resolve/AddressResolve_DefaultImpl.h\"
	USE_ZAP_CONFIG
)

list(
	APPEND lib_chip_main_sources

	${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_hook.c
	${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_table.c
	${MATTER_DIR}/examples/matter_example_entry.c
	${MATTER_DIR}/common/mbedtls/mbedtls_memory.c

	${CHIPDIR}/examples/providers/DeviceInfoProviderImpl.cpp

	${CHIPDIR}/src/app/icd/server/ICDMonitoringTable.cpp
	${CHIPDIR}/src/app/server/AclStorage.cpp
	${CHIPDIR}/src/app/server/DefaultAclStorage.cpp
	${CHIPDIR}/src/app/server/EchoHandler.cpp
	${CHIPDIR}/src/app/server/Dnssd.cpp
	${CHIPDIR}/src/app/server/OnboardingCodesUtil.cpp
	${CHIPDIR}/src/app/server/Server.cpp
	${CHIPDIR}/src/app/server/CommissioningWindowManager.cpp

	${CHIPDIR}/src/app/util/attribute-storage.cpp
	${CHIPDIR}/src/app/util/attribute-table.cpp
	${CHIPDIR}/src/app/util/binding-table.cpp
	${CHIPDIR}/src/app/util/DataModelHandler.cpp
	${CHIPDIR}/src/app/util/ember-compatibility-functions.cpp
	${CHIPDIR}/src/app/util/ember-global-attribute-access-interface.cpp
	${CHIPDIR}/src/app/util/ember-io-storage.cpp
	${CHIPDIR}/src/app/util/generic-callback-stubs.cpp
	${CHIPDIR}/src/app/util/util.cpp
	${CHIPDIR}/src/app/util/privilege-storage.cpp

	${CHIPDIR}/src/app/reporting/Engine.cpp
	${CHIPDIR}/src/app/reporting/reporting.cpp
)

file(STRINGS ${CODEGENDIR}/cluster-file.txt CLUSTER_LIST)
foreach(line IN LISTS CLUSTER_LIST)
  list(APPEND lib_chip_main_sources "${line}")
endforeach()

list(
	APPEND lib_chip_main_sources

	${CODEGENDIR}/app/callback-stub.cpp
	${CODEGENDIR}/app/cluster-init-callback.cpp
	${CODEGENDIR}/zap-generated/IMClusterCommandHandler.cpp

	${CHIPDIR}/zzz_generated/app-common/app-common/zap-generated/attributes/Accessors.cpp
	${CHIPDIR}/zzz_generated/app-common/app-common/zap-generated/cluster-objects.cpp

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp
)

if(CHIP_ENABLE_OTA_REQUESTOR)
list(
	APPEND lib_chip_main_sources
	${MATTER_DIR}/core/matter_ota_initializer.cpp
)
endif()

list(
	APPEND lib_chip_main_sources
	# lighting-app source files
	${MATTER_DIR}/drivers/device/led_driver.cpp
	${MATTER_EXAMPLEDIR}/light/example_matter_light.cpp
	${MATTER_EXAMPLEDIR}/light/matter_drivers.cpp

	${MATTER_DIR}/api/matter_api.cpp
	${MATTER_DIR}/core/matter_device_utils.cpp
)

#TODO
#lib_version
# VER_C += $(TARGET)_version.c
