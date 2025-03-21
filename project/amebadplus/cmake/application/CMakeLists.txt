set(DIR         ${BASEDIR}/component/application/matter)
set(ATCMDDIR    ${BASEDIR}/component/application/matter/common/atcmd)
set(BTDIR       ${BASEDIR}/component/application/matter/common/bluetooth)
set(FSKVDIR     ${BASEDIR}/component/application/matter/common/file_system/kv)
set(LWIPDIR     ${BASEDIR}/component/application/matter/common/lwip)
set(MBEDDIR     ${BASEDIR}/component/application/matter/common/mbedtls)
set(PORTDIR     ${BASEDIR}/component/application/matter/common/port)
set(PROTOBUFDIR ${BASEDIR}/component/application/matter/common/protobuf)
set(NANOPBDIR   ${BASEDIR}/component/application/matter/common/protobuf/nanopb)
set(EXAMPLEDIR  ${BASEDIR}/component/application/matter/example)
set(CHIPTESTDIR ${BASEDIR}/component/application/matter/example/chiptest)

set(MODULE_IFLAGS
    ${MBEDTLSDIR}/library
    ${BASEDIR}/component/application/matter/example
)

set(
    CSRC 
    # Matter AT Command
    ${ATCMDDIR}/atcmd_matter.c

    # Matter BLE
    ${BTDIR}/matter_blemgr_common.c
    ${BTDIR}/ble_matter_adapter_peripheral/ble_matter_adapter_service.c
    ${BTDIR}/ble_matter_adapter_peripheral/ble_matter_adapter_peripheral_main.c

    # Matter KV
    ${FSKVDIR}/kv_matter.c

    # Matter LwIP
    ${LWIPDIR}/api/lwip_netconf_matter.c
    ${LWIPDIR}/hooks/lwip_default_hooks.c

    # Matter MBEDTLS
    # ${MBEDDIR}/net_sockets.c #no need to include as latest mbedtls has it

    # Matter Common code porting
    ${PORTDIR}/matter_kvs.c
    ${PORTDIR}/matter_ota.c
    ${PORTDIR}/matter_timers.c
    ${PORTDIR}/matter_utils.c
    ${PORTDIR}/matter_wifis.c
    ${PORTDIR}/matter_lwip.c

    # Matter Factory data
    ${PROTOBUFDIR}/ameba_factory.pb.c
    ${NANOPBDIR}/pb_common.c
    ${NANOPBDIR}/pb_decode.c
    ${NANOPBDIR}/pb_encode.c

    # Matter Example
    ${CHIPTESTDIR}/example_matter.c
    ${EXAMPLEDIR}/matter_example_entry.c
)

ameba_internal_library(matter_application)
target_sources(${CURRENT_LIB_NAME} PRIVATE ${CSRC})
# target_compile_options(${CURRENT_LIB_NAME} PRIVATE ${GLOBAL_C_OPTIONS})
# target_include_directories(${CURRENT_LIB_NAME} PRIVATE ${GLOBAL_IFLAGS} ${MODULE_IFLAGS})
target_include_directories(${CURRENT_LIB_NAME} PRIVATE ${MODULE_IFLAGS})
