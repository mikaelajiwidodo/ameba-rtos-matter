cmake_minimum_required(VERSION 3.6)

include(${prj_root}/GCC-RELEASE/includepath.cmake)

if(NOT DEFINED MATTER_DIR)
set(MATTER_DIR        "${sdk_root}/component/application/matter")
endif()
if(NOT DEFINED MATTER_CMAKEDIR)
set(MATTER_CMAKEDIR   "${MATTER_DIR}/project/amebapro2/cmake")
endif()
set(CHIPDIR           "${sdk_root}/third_party/connectedhomeip")
set(MATTER_EXAMPLEDIR "${MATTER_DIR}/examples")
set(MATTER_TOOLDIR    "${MATTER_DIR}/tools")

# get CHIP_ENABLE_AMEBA_DLOG value from platform_opts_matter.h
execute_process(
    COMMAND bash "-c" "grep '#define CONFIG_ENABLE_AMEBA_DLOG ' '${MATTER_DIR}/common/include/platform_opts_matter.h' | tr -s '[:space:]' | cut -d' ' -f3"
    OUTPUT_VARIABLE CONFIG_ENABLE_AMEBA_DLOG
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

option(CHIP_ENABLE_AMEBA_DLOG    "Enable Logging for Matter"       ${CONFIG_ENABLE_AMEBA_DLOG})
option(CHIP_ENABLE_CHIPOBLE      "Enable BLE for Matter"           ON)
option(CHIP_ENABLE_IPV4          "Enable IPv4 for Matter"          OFF)
option(CHIP_ENABLE_OTA_REQUESTOR "Enable OTA Requestor for Matter" ON)
option(CHIP_ENABLE_SHELL         "Enable Shell for Matter"         ON)

# HEADER FILE PATH
list(
	APPEND matter_inc_path
	
	${inc_path}

	# freertos
	${sdk_root}/component/os/freertos/${freertos}/Source/portable/GCC/ARM_CM33/non_secure
	${sdk_root}/component/os/freertos/${freertos}/Source/portable/GCC/ARM_CM33/secure

	# ssl
	${sdk_root}/component/ssl
	${sdk_root}/component/ssl/${mbedtls}/library

	# file_system
	${sdk_root}/component/file_system/dct
	${sdk_root}/component/file_system/ftl
	${sdk_root}/component/file_system/fwfs
	${sdk_root}/component/file_system/system_data

	${sdk_root}/component/soc/8735b/misc/platform

	# bluetooth
	${sdk_root}/component/bluetooth/driver
	${sdk_root}/component/bluetooth/driver/hci
	${sdk_root}/component/bluetooth/driver/inc
	${sdk_root}/component/bluetooth/driver/inc/hci
	${sdk_root}/component/bluetooth/driver/platform/amebapro2/inc
	${sdk_root}/component/bluetooth/os/osif
	${sdk_root}/component/bluetooth/rtk_stack/example
	${sdk_root}/component/bluetooth/rtk_stack/inc/app
	${sdk_root}/component/bluetooth/rtk_stack/inc/bluetooth/gap
	${sdk_root}/component/bluetooth/rtk_stack/inc/bluetooth/profile
	${sdk_root}/component/bluetooth/rtk_stack/inc/bluetooth/profile/client
	${sdk_root}/component/bluetooth/rtk_stack/inc/bluetooth/profile/server
	${sdk_root}/component/bluetooth/rtk_stack/inc/framework/bt
	${sdk_root}/component/bluetooth/rtk_stack/inc/framework/remote
	${sdk_root}/component/bluetooth/rtk_stack/inc/framework/sys
	${sdk_root}/component/bluetooth/rtk_stack/inc/os
	${sdk_root}/component/bluetooth/rtk_stack/inc/platform
	${sdk_root}/component/bluetooth/rtk_stack/inc/stack
	${sdk_root}/component/bluetooth/rtk_stack/src/ble/privacy
	${sdk_root}/component/bluetooth/rtk_stack/platform/amebapro2/inc
	${sdk_root}/component/bluetooth/rtk_stack/platform/amebapro2/lib
	${sdk_root}/component/bluetooth/rtk_stack/platform/amebapro2/src/vendor_cmd
	${sdk_root}/component/bluetooth/rtk_stack/platform/common/inc
	${sdk_root}/component/bluetooth/rtk_stack/example/ble_central
	${sdk_root}/component/bluetooth/rtk_stack/example/ble_matter_adapter
	${sdk_root}/component/bluetooth/rtk_stack/example/ble_peripheral
	${sdk_root}/component/bluetooth/rtk_stack/example/ble_scatternet
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_beacon
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_config
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_airsync_config
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_mesh/provisioner
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_mesh/device
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_mesh_multiple_profile/provisioner_multiple_profile
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_mesh_multiple_profile/device_multiple_profile
	${sdk_root}/component/bluetooth/rtk_stack/example/bt_mesh_test

	# network
	${sdk_root}/component/network/coap/include
	${sdk_root}/component/network/mqtt/MQTTClient
	${sdk_root}/component/network/mqtt/MQTTPacket
	${sdk_root}/component/network/tftp
	${sdk_root}/component/network/ftp

	# nn
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/model_itp
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/nn_api
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/nn_postprocess
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/nn_preprocess
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/run_facerecog
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/nn/run_itp

	# audio
	${sdk_root}/component/audio/3rdparty/AEC

	# media
	${sdk_root}/component/example/media_framework/inc
	${sdk_root}/component/media/framework

	# video
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/video/osd
	${sdk_root}/component/soc/8735b/fwlib/rtl8735b/lib/source/ram/video/voe_bin

	${sdk_root}/component/video/osd2
	${sdk_root}/component/video/eip
	${sdk_root}/component/video/md

	${sdk_root}/component/soc/8735b/misc/driver
	${sdk_root}/component/soc/8735b/misc/driver/xmodem

	# usb
	${sdk_root}/component/usb
	${sdk_root}/component/usb/common_new
	${sdk_root}/component/usb/host_new
	${sdk_root}/component/usb/host_new/cdc_ecm
	${sdk_root}/component/usb/host_new/core
	${sdk_root}/component/usb/device_new/core

	# wifi
	${sdk_root}/component/wifi/driver/src/core/option
	${sdk_root}/component/wifi/wpa_supplicant/src

	# Ameba Matter Common Include folder list
	# -------------------------------------------------------------------
	${sdk_root}/component/application/matter/api
	${sdk_root}/component/application/matter/drivers/device
	${sdk_root}/component/application/matter/drivers/matter_consoles
	${sdk_root}/component/application/matter/drivers/matter_drivers
)

list(
	APPEND ameba_pro2_flags

	__thumb2__
	CONFIG_PLATFORM_8735B
	ARM_MATH_ARMV8MML
	__FPU_PRESENT
	__ARM_ARCH_7M__=0
	__ARM_ARCH_7EM__=0
	__ARM_ARCH_8M_MAIN__=1
	__ARM_ARCH_8M_BASE__=0
	__ARM_FEATURE_FP16_SCALAR_ARITHMETIC=1
	__DSP_PRESENT=1
	__ARMVFP__
)

list(
	APPEND matter_flags

    # Chip device options
	CHIP_DEVICE_LAYER_TARGET=Ameba
	CHIP_DEVICE_LAYER_NONE=0

    # Chip System options
	CHIP_SYSTEM_CONFIG_USE_ZEPHYR_NET_IF=0
	CHIP_SYSTEM_CONFIG_USE_BSD_IFADDRS=0
	CHIP_SYSTEM_CONFIG_USE_ZEPHYR_SOCKET_EXTENSIONS=0
	CHIP_SYSTEM_CONFIG_USE_LWIP=1
	CHIP_SYSTEM_CONFIG_USE_SOCKETS=0
	CHIP_SYSTEM_CONFIG_USE_NETWORK_FRAMEWORK=0
	CHIP_SYSTEM_CONFIG_POSIX_LOCKING=0
	CHIP_SHELL_MAX_TOKENS=11

    # LwIP options
	FD_SETSIZE=10
	LWIP_IPV6_ROUTE_TABLE_SUPPORT=1

    # Mbedtls options
	MBEDTLS_CONFIG_FILE=\"mbedtls_config.h\"

    # other options
	CHIP_HAVE_CONFIG_H

    # -------------------------------------------------------------------
    # Ameba plaftorm matter options
    # -------------------------------------------------------------------
	CONFIG_MATTER=1

    # Ameba platform blemgr adapter
	CONFIG_BT=1
	CONFIG_MATTER_BLEMGR_ADAPTER=0

    # Ameba platform factory data options
	CONFIG_ENABLE_AMEBA_FACTORY_DATA=0
	CONFIG_ENABLE_FACTORY_DATA_ENCRYPTION=0

    # Ameba platform additional secure feature
	CONFIG_ENABLE_AMEBA_CRYPTO=0

    # Ameba platform TestEvent Trigger EnableKey
	CONFIG_ENABLE_AMEBA_TEST_EVENT_TRIGGER=0

    # Ameba platform dct options
	CONFIG_ENABLE_DCT_ENCRYPTION=0

    # Ameba platform PRNG options
	CONFIG_ENABLE_MATTER_PRNG=0
)

# Diagnostic Logs Support
if(CHIP_ENABLE_AMEBA_DLOG)
list(
	APPEND matter_flags
	CHIP_CONFIG_ERROR_SOURCE=1
	CHIP_CONFIG_ERROR_FORMAT_AS_STRING=1
	CHIP_CONFIG_ENABLE_BDX_LOG_TRANSFER=1
)
endif()

# Chip BLE options
if(CHIP_ENABLE_CHIPOBLE)
list(APPEND matter_flags CHIP_DEVICE_CONFIG_ENABLE_CHIPOBLE=1)
else()
list(APPEND matter_flags CHIP_DEVICE_CONFIG_ENABLE_CHIPOBLE=0)
endif()

# Chip IPv4 
if(CHIP_ENABLE_IPV4)
list(APPEND matter_flags INET_CONFIG_ENABLE_IPV4=1)
else()
list(APPEND matter_flags INET_CONFIG_ENABLE_IPV4=0)
endif()

# Matter OTA Flags
if(CHIP_ENABLE_OTA_REQUESTOR)
list(APPEND matter_flags CONFIG_ENABLE_OTA_REQUESTOR=1)
else()
list(APPEND matter_flags CONFIG_ENABLE_OTA_REQUESTOR=0)
endif()
