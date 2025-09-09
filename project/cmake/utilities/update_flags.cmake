
function(MODIFY_TARGET_FLAGS TARGET)
    # Get current compile options
    get_target_property(TARGET_COMPILE_OPTIONS ${TARGET} COMPILE_OPTIONS)
    if(NOT TARGET_COMPILE_OPTIONS)
        set(TARGET_COMPILE_OPTIONS)
    endif()

    set(TARGET_C_COMPILE_OPTIONS)
    set(TARGET_CXX_COMPILE_OPTIONS)
    set(OTHER_FLAGS)

    # Parse existing flags
    foreach(FLAG ${TARGET_COMPILE_OPTIONS})
        if(FLAG MATCHES "^\\$<\\$<COMPILE_LANGUAGE:C>:([^>]*)>$")
            # Extract C flags
            string(REGEX REPLACE "^\\$<\\$<COMPILE_LANGUAGE:C>:([^>]*)>$" "\\1" C_FLAGS "${FLAG}")
            string(REPLACE ";" " " C_FLAGS "${C_FLAGS}")
            separate_arguments(C_FLAGS)
            list(APPEND TARGET_C_COMPILE_OPTIONS ${C_FLAGS})
        elseif(FLAG MATCHES "^\\$<\\$<COMPILE_LANGUAGE:CXX>:([^>]*)>$")
            # Extract CXX flags
            string(REGEX REPLACE "^\\$<\\$<COMPILE_LANGUAGE:CXX>:([^>]*)>$" "\\1" CXX_FLAGS "${FLAG}")
            string(REPLACE ";" " " CXX_FLAGS "${CXX_FLAGS}")
            separate_arguments(CXX_FLAGS)
            list(APPEND TARGET_CXX_COMPILE_OPTIONS ${CXX_FLAGS})
        else()
            list(APPEND OTHER_FLAGS "${FLAG}")
        endif()
    endforeach()

    # Modify C flags
    if(TARGET_C_COMPILE_OPTIONS)
        list(REMOVE_ITEM TARGET_C_COMPILE_OPTIONS 
            "-Wstrict-prototypes"
            "-std=c++11"
        )
        list(APPEND TARGET_C_COMPILE_OPTIONS "-Wno-sign-compare")
    endif()

    # Modify CXX flags
    if(TARGET_CXX_COMPILE_OPTIONS)
        list(REMOVE_ITEM TARGET_CXX_COMPILE_OPTIONS "-std=c++11")
        list(APPEND TARGET_CXX_COMPILE_OPTIONS "-std=gnu++17")
    endif()

    # Rebuild compile options
    set(NEW_COMPILE_OPTIONS)
    
    # Add modified C flags
    if(TARGET_C_COMPILE_OPTIONS)
        string(REPLACE ";" ";" ESCAPED_C_FLAGS "${TARGET_C_COMPILE_OPTIONS}")
        list(APPEND NEW_COMPILE_OPTIONS 
            "$<$<COMPILE_LANGUAGE:C>:${ESCAPED_C_FLAGS}>"
        )
    endif()

    # Add modified CXX flags
    if(TARGET_CXX_COMPILE_OPTIONS)
        string(REPLACE ";" ";" ESCAPED_CXX_FLAGS "${TARGET_CXX_COMPILE_OPTIONS}")
        list(APPEND NEW_COMPILE_OPTIONS 
            "$<$<COMPILE_LANGUAGE:CXX>:${ESCAPED_CXX_FLAGS}>"
        )
    endif()

    # Add other flags
    list(APPEND NEW_COMPILE_OPTIONS ${OTHER_FLAGS})

    # Update target properties
    set_target_properties(${TARGET} PROPERTIES
        COMPILE_OPTIONS "${NEW_COMPILE_OPTIONS}"
    )

    message(STATUS "Updated compile flags for target ${TARGET}:")
    message(STATUS "C Flags: ${TARGET_C_COMPILE_OPTIONS}")
    message(STATUS "CXX Flags: ${TARGET_CXX_COMPILE_OPTIONS}")
endfunction()
