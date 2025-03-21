#remove flags for compiling matter library

list(
	REMOVE_ITEM GLOBAL_C_DEFINES
	MBEDTLS_CONFIG_FILE="mbedtls/config.h"
)

list(
	REMOVE_ITEM GLOBAL_C_OPTIONS
	-fno-strict-aliasing
	-fno-strict-overflow
	-fno-delete-null-pointer-checks
	-Wstrict-prototypes
	-Wundef
	-Werror
	--save-temps
)

list(
	REMOVE_ITEM GLOBAL_CPP_OPTIONS
	-std=c++11
	-fno-use-cxa-atexit
	-Werror
)

# add compile flags

# Compile Warnings
list(
	APPEND GLOBAL_C_OPTIONS
	-Wno-sign-compare
	-Wno-unused-function
	-Wno-unused-but-set-variable
	-Wno-unused-variable
	-Wno-unused-label
	-Wno-deprecated-declarations
	-Wno-unused-parameter
	-Wno-format
	-Wno-format-nonliteral
	-Wno-format-security
	-Wno-address
	-Wno-stringop-truncation 
)

list(
	APPEND GLOBAL_CPP_OPTIONS
	
	-std=gnu++17
	-fno-rtti
)

list(
	APPEND GLOBAL_C_DEFINES

	CONFIG_MATTER=1

	# chip device options
	CHIP_DEVICE_LAYER_TARGET=Ameba
	CHIP_DEVICE_LAYER_NONE=0

	# chip System options
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
	MBEDTLS_CONFIG_FILE=\"matter_mbedtls_config.h\"
)

if(CONFIG_MATTER_SECURE_EN)
	list(
		APPEND GLOBAL_C_DEFINES
		# matter factory data options
		CONFIG_ENABLE_AMEBA_CRYPTO=1
		# matter additional secure options
		CONFIG_ENABLE_AMEBA_FACTORY_DATA=1
	)
else()
	list(
		APPEND GLOBAL_C_DEFINES
		CONFIG_ENABLE_AMEBA_FACTORY_DATA=0
	)
endif()

list(
	APPEND GLOBAL_C_DEFINES
	# matter factory data encryption options
	CONFIG_ENABLE_FACTORY_DATA_ENCRYPTION=0

	# matter kv options
	CONFIG_ENABLE_KV_ENCRYPTION=0

	# ameba TestEvent Trigger EnableKey
	CONFIG_ENABLE_AMEBA_TEST_EVENT_TRIGGER=0

	# ameba mdns filter options
	CONFIG_ENABLE_AMEBA_MDNS_FILTER=1

	# other options
	CHIP_HAVE_CONFIG_H

	# example options
	CONFIG_EXAMPLE_MATTER=1

	CONFIG_PLATFORM_AMEBALITE=1
)

# Diagnostic Logs Support
if(CHIP_ENABLE_AMEBA_DLOG)
	list(
		APPEND GLOBAL_C_DEFINES
		CHIP_CONFIG_ERROR_SOURCE=1
		CHIP_CONFIG_ERROR_FORMAT_AS_STRING=1
		CHIP_CONFIG_ENABLE_BDX_LOG_TRANSFER=1
	)
endif()

# Chip BLE options
if(CHIP_ENABLE_CHIPOBLE)
	list(APPEND GLOBAL_C_DEFINES CHIP_DEVICE_CONFIG_ENABLE_CHIPOBLE=1)
else()
	list(APPEND GLOBAL_C_DEFINES CHIP_DEVICE_CONFIG_ENABLE_CHIPOBLE=0)
endif()
if(CONFIG_BLE_MATTER_ADAPTER)
	list(APPEND GLOBAL_C_DEFINES CONFIG_MATTER_BLEMGR_ADAPTER=1)
else()
	list(APPEND GLOBAL_C_DEFINES CONFIG_MATTER_BLEMGR_ADAPTER=0)
endif()

# Chip IPv4 
if(CHIP_ENABLE_IPV4)
	list(APPEND GLOBAL_C_DEFINES INET_CONFIG_ENABLE_IPV4=1)
else()
	list(APPEND GLOBAL_C_DEFINES INET_CONFIG_ENABLE_IPV4=0)
endif()

# Matter OTA Flags
if(CHIP_ENABLE_OTA_REQUESTOR)
	list(APPEND GLOBAL_C_DEFINES CONFIG_ENABLE_OTA_REQUESTOR=1)
else()
	list(APPEND GLOBAL_C_DEFINES CONFIG_ENABLE_OTA_REQUESTOR=0)
endif()

if(MATTER_EXAMPLE STREQUAL "all_clusters")
	list(
		APPEND GLOBAL_C_DEFINES
		CONFIG_EXAMPLE_MATTER_CHIPTEST=1
	)
elseif(MATTER_EXAMPLE STREQUAL "light_port")
	list(
		APPEND GLOBAL_C_DEFINES
		CONFIG_EXAMPLE_MATTER_LIGHT=1
	)
endif()
# ifeq ($(EXAMPLE), aircon)
# 	CONFIG_EXAMPLE_MATTER_AIRCON=1
# endif
# ifeq ($(EXAMPLE), bridge)
# 	CONFIG_EXAMPLE_MATTER_BRIDGE=1
# endif
# ifeq ($(EXAMPLE), dishwasher)
# 	CONFIG_EXAMPLE_MATTER_DISHWASHER=1
# endif
# ifeq ($(EXAMPLE), fan)
# 	CONFIG_EXAMPLE_MATTER_FAN=1
# endif
# ifeq ($(EXAMPLE), light)
# 	CONFIG_EXAMPLE_MATTER_LIGHT=1
# endif
# ifeq ($(EXAMPLE), laundrywasher)
# 	CONFIG_EXAMPLE_MATTER_LAUNDRY_WASHER=1
# endif
# ifeq ($(EXAMPLE), microwaveoven)
# 	CONFIG_EXAMPLE_MATTER_MICROWAVE_OVEN=1
# endif
# ifeq ($(EXAMPLE), refrigerator)
# 	CONFIG_EXAMPLE_MATTER_REFRIGERATOR=1
# endif
# ifeq ($(EXAMPLE), thermostat)
# 	CONFIG_EXAMPLE_MATTER_THERMOSTAT=1
# endif
