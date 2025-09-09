ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${MATTER_DIR}/examples/bridge

	${CHIPDIR}/examples/all-clusters-app/all-clusters-common
	${CHIPDIR}/examples/bridge-app/bridge-common
	${CHIPDIR}/examples/bridge-app/ameba/main/include
	${CHIPDIR}/examples/bridge-app/ameba/build/chip/gen/include

)

ameba_list_append(private_sources

	# porting layer source files
	${MATTER_DIR}/core/matter_core.cpp
	${MATTER_DIR}/core/matter_interaction.cpp

	# bridge_port source files
	${MATTER_DIR}/drivers/device/bridge_driver.cpp
	${MATTER_DRIVER}/actions/ameba_actions_delegate.cpp
	${MATTER_DRIVER}/actions/ameba_actions_server.cpp
	${MATTER_DIR}/examples/bridge/example_matter_bridge.cpp
	${MATTER_DIR}/examples/bridge/matter_drivers.cpp

)
