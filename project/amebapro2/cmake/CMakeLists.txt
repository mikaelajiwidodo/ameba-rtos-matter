cmake_minimum_required(VERSION 3.6)

project(matter)

# root of SDK
get_filename_component(sdk_root "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../.." ABSOLUTE)
# root of realtek_amebapro2_v0_example
set(prj_root        "${sdk_root}/project/realtek_amebapro2_v0_example")
# matter related directory
set(MATTER_DIR      "${sdk_root}/component/application/matter")
set(MATTER_CMAKEDIR "${MATTER_DIR}/project/amebapro2/cmake")
# matter general cmake
set(MATTER_INCLUDE        "${MATTER_CMAKEDIR}/matter.cmake")
set(GENERATE_ARGS_GN      "${MATTER_CMAKEDIR}/utilities/generate_args_gn.cmake")
set(GENERATE_CLUSTER_FILE "${MATTER_CMAKEDIR}/utilities/generate_cluster_file.cmake")

include(${prj_root}/GCC-RELEASE/config.cmake)
include(${MATTER_INCLUDE})

# MATTER ZAP, CLUSTER, AND OUTPUT_DIR LIST
set(LIGHTING_FILE       "${CHIPDIR}/examples/lighting-app/ameba/build/chip/codegen/cluster-file.txt")
set(LIGHTING_ZAP        "${CHIPDIR}/examples/lighting-app/lighting-common/lighting-app.zap")
set(LIGHTING_OUTPUT_DIR "${CHIPDIR}/examples/lighting-app/ameba/build/chip")

# Set Matter files and directories based on the example
if("${MATTER_EXAMPLE}" STREQUAL "light_port")
	set(CLUSTER_FILE ${LIGHTING_FILE})
	set(ZAP_FILE     ${LIGHTING_ZAP})
	string(REPLACE ".zap" ".matter" MATTER_FILE "${ZAP_FILE}")
	set(OUTPUT_DIR ${LIGHTING_OUTPUT_DIR})
endif()
set(CODEGENDIR "${OUTPUT_DIR}/codegen")
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
	execute_process(COMMAND ${CMAKE_COMMAND} -DCODEGENDIR=${CODEGENDIR} -DCHIPDIR=${CHIPDIR} -DMATTER_TOOLDIR=${MATTER_TOOLDIR} -DMATTER_FILE=${MATTER_FILE} -DZAP_FILE=${ZAP_FILE} -DCLUSTER_FILE=${CLUSTER_FILE} -P ${GENERATE_CLUSTER_FILE})
else()
	message(FATAL_ERROR "${ZAP_FILE} does not exist.")
endif()
endif()
endif()

# generate cluster file again after clean_matter_libs is run
add_custom_command(
	OUTPUT ${CLUSTER_FILE}
	COMMAND ${CMAKE_COMMAND} -DCODEGENDIR=${CODEGENDIR} -DCHIPDIR=${CHIPDIR} -DMATTER_TOOLDIR=${MATTER_TOOLDIR} -DMATTER_FILE=${MATTER_FILE} -DZAP_FILE=${ZAP_FILE} -DCLUSTER_FILE=${CLUSTER_FILE} -P ${GENERATE_CLUSTER_FILE}
)

# Add flags, includes, and source files based on the example 
if(DEFINED MATTER_EXAMPLE AND MATTER_EXAMPLE)
	message(STATUS "MATTER_EXAMPLE = ${MATTER_EXAMPLE}")
	if(EXISTS ${MATTER_CMAKEDIR}/${MATTER_EXAMPLE})
		if(EXISTS ${MATTER_CMAKEDIR}/${MATTER_EXAMPLE}/${MATTER_EXAMPLE}.cmake)
			message(STATUS "Found ${MATTER_EXAMPLE} include project")
			include(${MATTER_CMAKEDIR}/${MATTER_EXAMPLE}/${MATTER_EXAMPLE}.cmake)
		else()
			message(FATAL_ERROR "Found ${MATTER_EXAMPLE} include project but ${MATTER_EXAMPLE}.cmake not exist")
		endif()
	else()
		message(FATAL_ERROR "${MATTER_EXAMPLE} Not Found")
	endif()
endif()

# Generate args.gn during setup
#C_FLAGS and CC_FLAGS
set(TARGET_C_FLAGS)
set(TARGET_CC_FLAGS)
separate_arguments(C_FLAGS_SEPERATED UNIX_COMMAND ${CMAKE_C_FLAGS})
foreach(item IN LISTS C_FLAGS_SEPERATED)
	set(TARGET_C_FLAGS "${TARGET_C_FLAGS}\"${item}\",")
	set(TARGET_CC_FLAGS "${TARGET_CC_FLAGS}\"${item}\",")
endforeach()
#INCLUDE_FLAGS
set(TARGET_INCLUDE_FLAGS)
foreach(item IN LISTS lib_chip_core_inc_path)
	set(TARGET_INCLUDE_FLAGS "${TARGET_INCLUDE_FLAGS}\"-I${item}\",")
endforeach()
#DEFINE_FLAGS
set(TARGET_DEFINE_FLAGS)
foreach(item IN LISTS ameba_pro2_flags)
	set(TARGET_DEFINE_FLAGS "${TARGET_DEFINE_FLAGS}\"-D${item}\",")
endforeach()
foreach(item IN LISTS lib_chip_core_flags)
	set(TARGET_DEFINE_FLAGS "${TARGET_DEFINE_FLAGS}\"-D${item}\",")
endforeach()

set(TARGET_CFLAGS_C   "${TARGET_C_FLAGS}${TARGET_DEFINE_FLAGS}${TARGET_INCLUDE_FLAGS}")
set(TARGET_CFLAGS_CC "${TARGET_CC_FLAGS}${TARGET_DEFINE_FLAGS}${TARGET_INCLUDE_FLAGS}")

execute_process(COMMAND ${CMAKE_COMMAND} -DCHIP_ENABLE_OTA_REQUESTOR=${CHIP_ENABLE_OTA_REQUESTOR} -DCHIP_ENABLE_CHIPOBLE=${CHIP_ENABLE_CHIPOBLE} -DCHIP_ENABLE_IPV4=${CHIP_ENABLE_IPV4} -DOUTPUT_DIR=${OUTPUT_DIR} -DCHIPDIR=${CHIPDIR} -DTARGET_CFLAGS_C=${TARGET_CFLAGS_C} -DTARGET_CFLAGS_CC=${TARGET_CFLAGS_CC} -P ${GENERATE_ARGS_GN})

# generate args.gn file again after clean_matter_libs is run
add_custom_command(
	OUTPUT  ${ARGS_GN}
	DEPENDS ${CLUSTER_FILE}
	COMMAND ${CMAKE_COMMAND} -DCHIP_ENABLE_OTA_REQUESTOR=${CHIP_ENABLE_OTA_REQUESTOR} -DCHIP_ENABLE_CHIPOBLE=${CHIP_ENABLE_CHIPOBLE} -DCHIP_ENABLE_IPV4=${CHIP_ENABLE_IPV4} -DOUTPUT_DIR=${OUTPUT_DIR} -DCHIPDIR=${CHIPDIR} -DTARGET_CFLAGS_C=\"${TARGET_CFLAGS_C}\" -DTARGET_CFLAGS_CC=\"${TARGET_CFLAGS_CC}\" -DREGEN_ARGS_GN=1 -P ${GENERATE_ARGS_GN}
)

# Compiling Configurations
add_library(
	lib_chip_main STATIC
	${lib_chip_main_sources}
)

target_compile_definitions(lib_chip_main PRIVATE ${lib_chip_main_flags})
target_include_directories(lib_chip_main PUBLIC  ${lib_chip_main_inc_path})
set_target_properties(
	lib_chip_main PROPERTIES
	PREFIX "lib_"
	OUTPUT_NAME "main"
	SUFFIX ".a"
	ARCHIVE_OUTPUT_DIRECTORY "${prj_root}/GCC-RELEASE/application/output"
)

# generate ninja
add_custom_target(
	GENERATE_NINJA

	DEPENDS ${ARGS_GN}

	COMMAND ${CMAKE_COMMAND} -E make_directory ${CHIPDIR}/config/ameba/components/chip
	COMMAND ${CMAKE_COMMAND} -E chdir ${CHIPDIR}/config/ameba/components/chip gn gen --check --fail-on-unused-args ${OUTPUT_DIR}
	COMMAND ${CMAKE_COMMAND} -E chdir ${CHIPDIR}/config/ameba/components/chip ninja -C ${OUTPUT_DIR} :ameba
	COMMAND ${CMAKE_COMMAND} -E copy ${OUTPUT_DIR}/lib/* ${sdk_root}/project/realtek_amebapro2_v0_example/GCC-RELEASE/application/output
)

# lib_chip_core is based on GENERATE_NINJA
add_custom_target(
	lib_chip_core
	DEPENDS GENERATE_NINJA
)

# before compiling lib_chip_main, make sure lib_chip_coreis compiled
add_dependencies(
	lib_chip_main
	lib_chip_core
)

# ${MATTER_EXAMPLE} is based on lib_chip_main and lib_chip_core
add_custom_target(
	${MATTER_EXAMPLE}
	DEPENDS lib_chip_main
)

# simplify target name to matter
add_custom_target(
	matter
	DEPENDS ${MATTER_EXAMPLE}
)

# matter clean target
add_custom_target(
	clean_matter_libs
	COMMAND ${CMAKE_COMMAND} -E rm -rf ${OUTPUT_DIR}
	COMMAND ${CMAKE_COMMAND} -E echo cleaned lib_chip_core
	COMMAND ${CMAKE_COMMAND} --build . --target clean
	COMMAND ${CMAKE_COMMAND} -E echo cleaned lib_chip_main
)