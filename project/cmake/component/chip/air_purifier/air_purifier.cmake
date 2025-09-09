ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${CHIPDIR}/examples/air-purifier-app/air-purifier-common
	${CHIPDIR}/examples/air-purifier-app/air-purifier-common/include
	${CHIPDIR}/examples/air-purifier-app/ameba/main/include
	${CHIPDIR}/examples/air-purifier-app/ameba/build/chip/gen/include
	${CODEGEN_DIR}
)

ameba_list_append(private_sources
	# air_purifier_app source files
	${CHIPDIR}/examples/air-purifier-app/ameba/main/chipinterface.cpp
	${CHIPDIR}/examples/air-purifier-app/ameba/main/DeviceCallbacks.cpp
	${CHIPDIR}/examples/air-purifier-app/ameba/main/CHIPDeviceManager.cpp
	${CHIPDIR}/examples/air-purifier-app/air-purifier-common/src/air-purifier-manager.cpp
	${CHIPDIR}/examples/air-purifier-app/air-purifier-common/src/air-quality-sensor-manager.cpp
	${CHIPDIR}/examples/air-purifier-app/air-purifier-common/src/filter-delegates.cpp
	${CHIPDIR}/examples/air-purifier-app/air-purifier-common/src/thermostat-manager.cpp
)
