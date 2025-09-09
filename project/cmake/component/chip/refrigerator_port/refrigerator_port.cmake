ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_EXAMPLEDIR}/refrigerator
	${MATTER_EXAMPLEDIR}/refrigerator/build/chip/gen/include

)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# refrigerator_port source files
	${MATTER_DIR}/drivers/device/refrigerator_driver.cpp
	${MATTER_DRIVER}/refrigerator_mode/ameba_refrigerator_mode_delegate.cpp
	${MATTER_DRIVER}/refrigerator_mode/ameba_refrigerator_mode_instance.cpp
	${MATTER_EXAMPLEDIR}/refrigerator/example_matter_refrigerator.cpp
	${MATTER_EXAMPLEDIR}/refrigerator/matter_drivers.cpp

)
