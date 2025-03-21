# matter general cmake
set(MATTER_INCLUDE        "${MATTER_CMAKEDIR}/matter.cmake")
set(GENERATE_ARGS_GN      "${MATTER_CMAKEDIR}/utilities/generate_args_gn.cmake")
set(GENERATE_CLUSTER_FILE "${MATTER_CMAKEDIR}/utilities/generate_cluster_file.cmake")

# include(${MATTER_INCLUDE})

# MATTER ZAP, CLUSTER, AND OUTPUT_DIR LIST
set(ALL_CLUSTERS_FILE       "${CHIPDIR}/examples/all-clusters-app/ameba/build/chip/codegen/cluster-file.txt")
set(ALL_CLUSTERS_ZAP        "${CHIPDIR}/examples/all-clusters-app/all-clusters-common/all-clusters-app.zap")
set(ALL_CLUSTERS_OUTPUT_DIR "${CHIPDIR}/examples/all-clusters-app/ameba/build/chip")
set(LIGHTING_FILE           "${CHIPDIR}/examples/lighting-app/ameba/build/chip/codegen/cluster-file.txt")
set(LIGHTING_ZAP            "${CHIPDIR}/examples/lighting-app/lighting-common/lighting-app.zap")
set(LIGHTING_OUTPUT_DIR     "${CHIPDIR}/examples/lighting-app/ameba/build/chip")

# Set Matter files and directories based on the example
if("${MATTER_EXAMPLE}" STREQUAL "all_clusters")
	set(CLUSTER_FILE ${ALL_CLUSTERS_FILE})
	set(ZAP_FILE     ${ALL_CLUSTERS_ZAP})
	string(REPLACE ".zap" ".matter" MATTER_FILE "${ZAP_FILE}")
	set(OUTPUT_DIR ${ALL_CLUSTERS_OUTPUT_DIR})
elseif("${MATTER_EXAMPLE}" STREQUAL "light_port")
	set(CLUSTER_FILE ${LIGHTING_FILE})
	set(ZAP_FILE     ${LIGHTING_ZAP})
	string(REPLACE ".zap" ".matter" MATTER_FILE "${ZAP_FILE}")
	set(OUTPUT_DIR ${LIGHTING_OUTPUT_DIR})
endif()
set(CODEGEN_DIR "${OUTPUT_DIR}/codegen")
set(ARGS_GN "${OUTPUT_DIR}/args.gn")

message(STATUS "CLUSTER_FILE :${CLUSTER_FILE}")
message(STATUS "ZAP_FILE     :${ZAP_FILE}")
message(STATUS "MATTER_FILE  :${MATTER_FILE}")
message(STATUS "OUTPUT_DIR   :${OUTPUT_DIR}")

# Generate cluster file during setup
if(DEFINED MATTER_EXAMPLE)
if(NOT EXISTS ${CLUSTER_FILE})
if(EXISTS ${ZAP_FILE})
	message(STATUS "${ZAP_FILE} exists")
	execute_process(COMMAND ${CMAKE_COMMAND} -DCODEGEN_DIR=${CODEGEN_DIR} -DCHIPDIR=${CHIPDIR} -DMATTER_TOOLDIR=${MATTER_TOOLDIR} -DMATTER_FILE=${MATTER_FILE} -DZAP_FILE=${ZAP_FILE} -DCLUSTER_FILE=${CLUSTER_FILE} -P ${GENERATE_CLUSTER_FILE})
else()
	message(FATAL_ERROR "${ZAP_FILE} does not exist.")
endif()
endif()
endif()

# generate cluster file again after clean_matter_libs is run
add_custom_command(
	OUTPUT ${CLUSTER_FILE}
	COMMAND ${CMAKE_COMMAND} -DCODEGEN_DIR=${CODEGEN_DIR} -DCHIPDIR=${CHIPDIR} -DMATTER_TOOLDIR=${MATTER_TOOLDIR} -DMATTER_FILE=${MATTER_FILE} -DZAP_FILE=${ZAP_FILE} -DCLUSTER_FILE=${CLUSTER_FILE} -P ${GENERATE_CLUSTER_FILE}
)

# Add flags, includes, and source files based on the example 
if(DEFINED MATTER_EXAMPLE AND MATTER_EXAMPLE)
	message(STATUS "MATTER_EXAMPLE = ${MATTER_EXAMPLE}")
	if(EXISTS ${MATTER_CMAKEDIR}/chip/${MATTER_EXAMPLE})
		if(EXISTS ${MATTER_CMAKEDIR}/chip/${MATTER_EXAMPLE}/${MATTER_EXAMPLE}.cmake)
			message(STATUS "Found ${MATTER_EXAMPLE} include project")
			include(${MATTER_CMAKEDIR}/chip/${MATTER_EXAMPLE}/${MATTER_EXAMPLE}.cmake)
		else()
			message(FATAL_ERROR "Found ${MATTER_EXAMPLE} include project but ${MATTER_EXAMPLE}.cmake not exist")
		endif()
	else()
		message(FATAL_ERROR "${MATTER_EXAMPLE} Not Found")
	endif()
endif()

# Generate args.gn during setup
# TARGET_COMPILE_FLAGS
set(TARGET_COMPILE_FLAGS)
foreach(item IN LISTS GLOBAL_C_OPTIONS)
	set(TARGET_COMPILE_FLAGS "${TARGET_COMPILE_FLAGS}\"${item}\",")
	# message(STATUS "adding ${item} of GLOBAL_C_OPTIONS")
endforeach()
# INCLUDE_FLAGS
set(TARGET_INCLUDE_FLAGS)
foreach(item IN LISTS LIB_CHIP_CORE_INC_PATH)
	set(TARGET_INCLUDE_FLAGS "${TARGET_INCLUDE_FLAGS}\"-I${item}\",")
endforeach()
#DEFINE_FLAGS
set(TARGET_DEFINE_FLAGS)
foreach(item IN LISTS LIB_CHIP_CORE_FLAGS)
	set(TARGET_DEFINE_FLAGS "${TARGET_DEFINE_FLAGS}\"-D${item}\",")
endforeach()

set(TARGET_CFLAGS_C  "${TARGET_COMPILE_FLAGS}${TARGET_DEFINE_FLAGS}${TARGET_INCLUDE_FLAGS}")
set(TARGET_CFLAGS_CC "${TARGET_COMPILE_FLAGS}${TARGET_DEFINE_FLAGS}${TARGET_INCLUDE_FLAGS}")

execute_process(COMMAND ${CMAKE_COMMAND} -DCHIP_ENABLE_OTA_REQUESTOR=${CHIP_ENABLE_OTA_REQUESTOR} -DCHIP_ENABLE_CHIPOBLE=${CHIP_ENABLE_CHIPOBLE} -DCHIP_ENABLE_IPV4=${CHIP_ENABLE_IPV4} -DOUTPUT_DIR=${OUTPUT_DIR} -DCHIPDIR=${CHIPDIR} -DTARGET_CFLAGS_C=${TARGET_CFLAGS_C} -DTARGET_CFLAGS_CC=${TARGET_CFLAGS_CC} -P ${GENERATE_ARGS_GN})

# generate args.gn file again after clean_matter_libs is run
add_custom_command(
	OUTPUT  ${ARGS_GN}
	DEPENDS ${CLUSTER_FILE}
	COMMAND ${CMAKE_COMMAND} -DCHIP_ENABLE_OTA_REQUESTOR=${CHIP_ENABLE_OTA_REQUESTOR} -DCHIP_ENABLE_CHIPOBLE=${CHIP_ENABLE_CHIPOBLE} -DCHIP_ENABLE_IPV4=${CHIP_ENABLE_IPV4} -DOUTPUT_DIR=${OUTPUT_DIR} -DCHIPDIR=${CHIPDIR} -DTARGET_CFLAGS_C=\"${TARGET_CFLAGS_C}\" -DTARGET_CFLAGS_CC=\"${TARGET_CFLAGS_CC}\" -DREGEN_ARGS_GN=1 -P ${GENERATE_ARGS_GN}
)

# Compiling Configurations
ameba_app_library(chip_main)
target_sources(${CURRENT_LIB_NAME} PRIVATE ${LIB_CHIP_MAIN_SOURCES})
target_compile_definitions(${CURRENT_LIB_NAME} PRIVATE ${LIB_CHIP_MAIN_FLAGS})
target_include_directories(${CURRENT_LIB_NAME} PRIVATE ${LIB_CHIP_MAIN_INC_PATH})

add_custom_command(
	OUTPUT ${PROJECTDIR}/asdk/lib/application/lib_chip_core.a

	DEPENDS ${ARGS_GN}

	COMMAND ${CMAKE_COMMAND} -E make_directory ${CHIPDIR}/config/ameba/components/chip
	COMMAND ${CMAKE_COMMAND} -E chdir ${CHIPDIR}/config/ameba/components/chip gn gen --check --fail-on-unused-args ${OUTPUT_DIR}
	COMMAND ${CMAKE_COMMAND} -E chdir ${CHIPDIR}/config/ameba/components/chip ninja -C ${OUTPUT_DIR} :ameba
	COMMAND ${CMAKE_COMMAND} -E copy ${OUTPUT_DIR}/lib/* ${PROJECTDIR}/asdk/lib/application/
	COMMAND ${CMAKE_COMMAND} -E rename ${PROJECTDIR}/asdk/lib/application/libCHIP.a ${PROJECTDIR}/asdk/lib/application/lib_chip_core.a
)

# lib_chip_core is based on GENERATE_NINJA
add_custom_target(
	lib_chip_core
	DEPENDS ${PROJECTDIR}/asdk/lib/application/lib_chip_core.a
)

# before compiling lib_chip_main, make sure lib_chip_core is compiled
add_dependencies(
	${CURRENT_LIB_NAME}
	lib_chip_core
)

# matter clean target
add_custom_target(
	clean_matter_libs
	COMMAND ${CMAKE_COMMAND} -E rm -rf ${OUTPUT_DIR}
	COMMAND ${CMAKE_COMMAND} -E rm -rf ${PROJECTDIR}/asdk/lib/application/lib_chip_core.a
	COMMAND ${CMAKE_COMMAND} -E echo cleaned lib_chip_core
	COMMAND ${CMAKE_COMMAND} -E rm -rf ${PROJECTDIR}/asdk/lib/application/lib_chip_main.a
	COMMAND ${CMAKE_COMMAND} -E echo cleaned lib_chip_main
)