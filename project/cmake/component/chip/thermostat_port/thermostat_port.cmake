ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_EXAMPLEDIR}/thermostat

	${CHIPDIR}/examples/thermostat/thermostat-common
	${CHIPDIR}/examples/thermostat/ameba/main/include
	${CHIPDIR}/examples/thermostat/ameba/build/chip/gen/include

)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# thermostat_port source files
	${MATTER_DIR}/drivers/device/thermostat_driver.cpp
	${MATTER_DIR}/drivers/device/thermostat_ui_driver.cpp
	${MATTER_EXAMPLEDIR}/thermostat/example_matter_thermostat.cpp
	${MATTER_EXAMPLEDIR}/thermostat/matter_drivers.cpp

)
