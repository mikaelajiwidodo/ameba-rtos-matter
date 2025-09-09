list(APPEND LIB_CHIP_CORE_INC_PATH

    ${GLOBAL_INTERFACE_INCLUDES} #needed for the args.gn arguments

    ${MATTER_DIR}/common/wifi

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

ameba_list_append(private_includes

    # ${GLOBAL_INTERFACE_INCLUDES} #not needed

    ${MATTER_DIR}/api
    ${MATTER_DIR}/core
    ${MATTER_DIR}/common/wifi
    ${MATTER_DIR}/drivers/device
    ${MATTER_DIR}/drivers/matter_consoles
    ${MATTER_DIR}/drivers/matter_drivers

    ${CHIPDIR}/examples/platform/ameba
    ${CHIPDIR}/examples/providers
    ${CHIPDIR}/src
    ${CHIPDIR}/src/app
    ${CHIPDIR}/src/app/util
    ${CHIPDIR}/src/app/server
    ${CHIPDIR}/src/controller/data_model
    ${CHIPDIR}/src/app/clusters/bindings
    ${CHIPDIR}/src/include
    ${CHIPDIR}/src/lib
    ${CHIPDIR}/third_party/nlassert/repo/include
    ${CHIPDIR}/third_party/nlio/repo/include
    ${CHIPDIR}/third_party/nlunit-test/repo/src
    ${CHIPDIR}/zzz_generated
    ${CHIPDIR}/zzz_generated/app-common

    ${CODEGEN_DIR}
    ${CODEGEN_DIR}/zap-generated

)

list(APPEND LIB_CHIP_CORE_FLAGS

    ${c_GLOBAL_COMMON_COMPILE_DEFINES} #needed for the args.gn arguments
    ${c_GLOBAL_MCU_COMPILE_DEFINES}
    ${GLOBAL_INTERFACE_DEFINITIONS}
    ${matter_defintions}

    CHIP_PROJECT=1
)

ameba_list_append(private_definitions

    # ${GLOBAL_C_DEFINES} #not needed
    # ${c_GLOBAL_MCU_COMPILE_DEFINES}
    # ${matter_defintions}

    CHIP_PROJECT=1
    CHIP_ADDRESS_RESOLVE_IMPL_INCLUDE_HEADER=\"lib/address_resolve/AddressResolve_DefaultImpl.h\"
    CONFIG_ENABLE_AMEBA_APP_TASK=1
    CONFIG_ENABLE_AMEBA_ATTRIBUTE_CALLBACK=1
    USE_ZAP_CONFIG
)

ameba_list_append(private_sources

    # connectedhomeip - examples
    ${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_hook.c
    ${CHIPDIR}/examples/platform/ameba/route_hook/ameba_route_table.c

    # connectedhomeip - src - app
    ${CHIPDIR}/src/app/SafeAttributePersistenceProvider.cpp
    ${CHIPDIR}/src/app/StorageDelegateWrapper.cpp
    ${CHIPDIR}/src/app/icd/server/ICDMonitoringTable.cpp
    ${CHIPDIR}/src/app/icd/server/ICDConfigurationData.cpp
    ${CHIPDIR}/src/app/reporting/Engine.cpp
    ${CHIPDIR}/src/app/reporting/reporting.cpp

    # connectedhomeip - src - app - clusters
    # ${CHIPDIR}/src/app/clusters/bindings/binding-table.cpp

    # connectedhomeip - src - app - server
    ${CHIPDIR}/src/app/server/AclStorage.cpp
    ${CHIPDIR}/src/app/server/DefaultAclStorage.cpp
    ${CHIPDIR}/src/app/server/EchoHandler.cpp
    ${CHIPDIR}/src/app/server/Dnssd.cpp
    ${CHIPDIR}/src/app/server/Server.cpp
    ${CHIPDIR}/src/app/server/CommissioningWindowManager.cpp

    # connectedhomeip - src - app - server-cluster
    ${CHIPDIR}/src/app/server-cluster/AttributeListBuilder.cpp
    ${CHIPDIR}/src/app/server-cluster/DefaultServerCluster.cpp
    ${CHIPDIR}/src/app/server-cluster/ServerClusterInterface.cpp
    ${CHIPDIR}/src/app/server-cluster/ServerClusterInterfaceRegistry.cpp
    ${CHIPDIR}/src/app/server-cluster/SingleEndpointServerClusterRegistry.cpp

    # connectedhomeip - src - app - util
    ${CHIPDIR}/src/app/util/attribute-storage.cpp
    ${CHIPDIR}/src/app/util/attribute-table.cpp
    ${CHIPDIR}/src/app/util/DataModelHandler.cpp
    ${CHIPDIR}/src/app/util/ember-io-storage.cpp
    ${CHIPDIR}/src/app/util/generic-callback-stubs.cpp
    ${CHIPDIR}/src/app/util/util.cpp
    ${CHIPDIR}/src/app/util/privilege-storage.cpp

    # connectedhomeip - src - app - persistence
    ${CHIPDIR}/src/app/persistence/AttributePersistence.cpp
    ${CHIPDIR}/src/app/persistence/AttributePersistenceProviderInstance.cpp
    ${CHIPDIR}/src/app/persistence/DefaultAttributePersistenceProvider.cpp
    ${CHIPDIR}/src/app/persistence/DeferredAttributePersistenceProvider.cpp
    ${CHIPDIR}/src/app/persistence/String.cpp

    # connectedhomeip - src - data-model-providers
    ${CHIPDIR}/src/data-model-providers/codegen/ClusterIntegration.cpp
    ${CHIPDIR}/src/data-model-providers/codegen/CodegenDataModelProvider.cpp
    ${CHIPDIR}/src/data-model-providers/codegen/CodegenDataModelProvider_Read.cpp
    ${CHIPDIR}/src/data-model-providers/codegen/CodegenDataModelProvider_Write.cpp
    ${CHIPDIR}/src/data-model-providers/codegen/EmberAttributeDataBuffer.cpp
    ${CHIPDIR}/src/data-model-providers/codegen/Instance.cpp

    # connectedhomeip - src - setup_payload
    ${CHIPDIR}/src/setup_payload/OnboardingCodesUtil.cpp

    ${CHIPDIR}/zzz_generated/app-common/app-common/zap-generated/attributes/Accessors.cpp
    ${CHIPDIR}/zzz_generated/app-common/app-common/zap-generated/cluster-objects.cpp

)

# connectedhomeip - codegen - cluster-file.txt
file(STRINGS ${CODEGEN_DIR}/cluster-file.txt CLUSTER_LIST)
foreach(line IN LISTS CLUSTER_LIST)
    ameba_list_append(private_sources "${line}")
endforeach()

ameba_list_append(private_sources

    # connectedhomeip - codegen
    ${CODEGEN_DIR}/app/callback-stub.cpp
    ${CODEGEN_DIR}/app/cluster-callbacks.cpp
    ${CODEGEN_DIR}/zap-generated/CodeDrivenInitShutdown.cpp
    ${CODEGEN_DIR}/zap-generated/IMClusterCommandHandler.cpp

    # matter - api
    ${MATTER_DIR}/api/matter_api.cpp

    # matter - core
    ${MATTER_DIR}/core/matter_device_utils.cpp
    ${MATTER_DIR}/core/matter_test_event_trigger.cpp # Not using AmebaTestEventTriggerDelegate.cpp

)

# connectedhomeip - src - app - server - T&C
if(CHIP_ENABLE_TC)
ameba_list_append(private_sources
    ${CHIPDIR}/src/app/server/DefaultTermsAndConditionsProvider.cpp
    ${CHIPDIR}/src/app/server/TermsAndConditionsManager.cpp
)
endif()

if(CHIP_ENABLE_OTA_REQUESTOR)
ameba_list_append(private_sources
    ${CHIPDIR}/examples/platform/ameba/ota/OTAInitializer.cpp
)
endif()

if(CHIP_ENABLE_SHELL)
ameba_list_append(private_sources
    ${CHIPDIR}/examples/platform/ameba/shell/launch_shell.cpp
)
endif()
