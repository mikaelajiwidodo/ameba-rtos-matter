ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_EXAMPLEDIR}/aircon
	${MATTER_EXAMPLEDIR}/aircon/build/chip/gen/include

)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/api/matter_api.cpp
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_device_utils.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# aircon_port source files
	${MATTER_DIR}/drivers/device/room_aircon_driver.cpp
	${MATTER_DIR}/drivers/device/temp_hum_sensor_driver.cpp
	${MATTER_EXAMPLEDIR}/aircon/example_matter_aircon.cpp
	${MATTER_EXAMPLEDIR}/aircon/matter_drivers.cpp
)
