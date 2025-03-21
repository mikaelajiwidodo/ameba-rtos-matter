list(
	APPEND LIB_CHIP_CORE_INC_PATH

	${GLOBAL_IFLAGS} #needed for the args.gn arguments

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
	APPEND LIB_CHIP_MAIN_INC_PATH

	# ${GLOBAL_IFLAGS} #not needed

	${MATTER_DIR}/api
	${MATTER_DIR}/core
	${MATTER_DIR}/driver
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
	${CODEGEN_DIR}
)

list(
	APPEND LIB_CHIP_CORE_FLAGS

	${GLOBAL_C_DEFINES} #needed for the args.gn arguments

	CHIP_PROJECT=1
)

list(
	APPEND LIB_CHIP_MAIN_FLAGS

	# ${GLOBAL_C_DEFINES} #not needed

	CHIP_PROJECT=1
	CHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER=\"lib/address_resolve/AddressResolve_DefaultImpl.h\"
	USE_ZAP_CONFIG
)

list(
	APPEND LIB_CHIP_MAIN_SOURCES

	${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_hook.c
	${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_table.c

	${CHIPDIR}/examples/providers/DeviceInfoProviderImpl.cpp

	${CHIPDIR}/src/app/server/AclStorage.cpp
	${CHIPDIR}/src/app/server/DefaultAclStorage.cpp
	${CHIPDIR}/src/app/server/Server.cpp
	${CHIPDIR}/src/app/server/Dnssd.cpp
	${CHIPDIR}/src/app/server/EchoHandler.cpp
	${CHIPDIR}/src/app/server/OnboardingCodesUtil.cpp
	${CHIPDIR}/src/app/server/CommissioningWindowManager.cpp
	
	${CHIPDIR}/src/app/icd/server/ICDMonitoringTable.cpp
	${CHIPDIR}/src/app/util/attribute-storage.cpp
	${CHIPDIR}/src/app/util/attribute-table.cpp
	${CHIPDIR}/src/app/util/binding-table.cpp
	${CHIPDIR}/src/app/util/DataModelHandler.cpp
	${CHIPDIR}/src/app/util/ember-compatibility-functions.cpp
	${CHIPDIR}/src/app/util/generic-callback-stubs.cpp
	${CHIPDIR}/src/app/util/util.cpp
	${CHIPDIR}/src/app/util/privilege-storage.cpp
	
	${CHIPDIR}/src/app/reporting/Engine.cpp
	${CHIPDIR}/src/app/reporting/reporting.cpp
	
	${CHIPDIR}/src/lib/dnssd/minimal_mdns/responders/IP.cpp
)

file(STRINGS ${CODEGEN_DIR}/cluster-file.txt CLUSTER_LIST)
foreach(line IN LISTS CLUSTER_LIST)
	list(APPEND LIB_CHIP_MAIN_SOURCES "${line}")
endforeach()

list(
	APPEND LIB_CHIP_MAIN_SOURCES

	${CODEGEN_DIR}/app/callback-stub.cpp
	${CODEGEN_DIR}/app/cluster-init-callback.cpp
	${CODEGEN_DIR}/zap-generated/IMClusterCommandHandler.cpp

	${CHIPDIR}/zzz_generated/app-common/app-common/zap-generated/attributes/Accessors.cpp

	# porting layer source files
	${MATTER_DIR}/api/matter_api.cpp
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp
)

if(CHIP_ENABLE_OTA_REQUESTOR)
list(
	APPEND LIB_CHIP_MAIN_SOURCES
	${MATTER_DIR}/core/matter_ota_initializer.cpp
)
endif()

list(
	APPEND LIB_CHIP_MAIN_SOURCES
	# lighting-app source files
	${MATTER_DIR}/driver/led_driver.cpp
	${MATTER_EXAMPLEDIR}/light/example_matter_light.cpp
	${MATTER_EXAMPLEDIR}/light/matter_drivers.cpp
)
