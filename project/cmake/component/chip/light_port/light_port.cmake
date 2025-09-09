ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_EXAMPLEDIR}/light

	${CHIPDIR}/examples/lighting-app/lighting-common
	${CHIPDIR}/examples/lighting-app/ameba/main/include
	${CHIPDIR}/examples/lighting-app/ameba/build/chip/gen/include
)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# light_port source files
	${MATTER_DIR}/drivers/device/led_driver.cpp
	${MATTER_EXAMPLEDIR}/light/example_matter_light.cpp
	${MATTER_EXAMPLEDIR}/light/matter_drivers.cpp

)
