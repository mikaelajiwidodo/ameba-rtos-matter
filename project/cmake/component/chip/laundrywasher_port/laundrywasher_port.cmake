ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_DIR}/examples/laundrywasher
	${MATTER_DIR}/examples/laundrywasher/build/chip/gen/include

)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# laundrywasher_port source files
	${MATTER_DIR}/drivers/device/washer_driver.cpp
	${MATTER_DRIVER}/laundry_washer_controls/ameba_laundry_washer_controls_delegate.cpp
	${MATTER_DRIVER}/laundry_washer_mode/ameba_laundry_washer_mode_delegate.cpp
	${MATTER_DRIVER}/laundry_washer_mode/ameba_laundry_washer_mode_instance.cpp
	${MATTER_DRIVER}/operational_state/ameba_operational_state_delegate.cpp
	${MATTER_DRIVER}/operational_state/ameba_operational_state_instance.cpp
	${MATTER_EXAMPLEDIR}/laundrywasher/example_matter_laundrywasher.cpp
	${MATTER_EXAMPLEDIR}/laundrywasher/matter_drivers.cpp

)
