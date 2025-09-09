ameba_list_append(private_includes

	# ${GLOBAL_INTERFACE_INCLUDES} #not needed

	${CHIPDIR}/examples/platform/ameba/observer
	${CHIPDIR}/examples/lighting-app/lighting-common
	${CHIPDIR}/examples/lighting-app/ameba/main/include
	${CHIPDIR}/examples/lighting-app/ameba/build/chip/gen/include

)

ameba_list_append(private_sources

	# light source files
	${CHIPDIR}/examples/lighting-app/ameba/main/chipinterface.cpp
	${CHIPDIR}/examples/lighting-app/ameba/main/DeviceCallbacks.cpp
	${CHIPDIR}/examples/lighting-app/ameba/main/CHIPDeviceManager.cpp
	${CHIPDIR}/examples/lighting-app/ameba/main/Globals.cpp
	${CHIPDIR}/examples/lighting-app/ameba/main/LEDWidget.cpp

)
