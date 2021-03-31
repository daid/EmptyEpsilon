cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# Set a default version.
# For historical reason, we first honor CPack variables if they are set.
if(DEFINED CPACK_PACKAGE_VERSION_MAJOR)
    message(DEPRECATION "Prefer setting the version through CMAKE_PROJECT_EmptyEpsilon_INCLUDE file override")
    set(MAJOR "${CPACK_PACKAGE_VERSION_MAJOR}")
    set(MINOR "${CPACK_PACKAGE_VERSION_MINOR}")
    set(PATCH "${CPACK_PACKAGE_VERSION_PATCH}")
else()
    # Following [CMake docs](https://cmake.org/cmake/help/v3.7/command/project.html) 
    # You can override these by setting CMAKE_PROJECT_EmptyEpsilon_INCLUDE=<a_file>
    # In which you'd define the following variables:
    # - PROJECT_VERSION
    # - PROJECT_VERSION_MAJOR
    # - PROJECT_VERSION_MINOR
    # - PROJECT_VERSION_PATCH
    string(TIMESTAMP MAJOR "%Y")
    string(TIMESTAMP MINOR "%m")
    string(TIMESTAMP PATCH "%d")
endif()

project(EmptyEpsilon LANGUAGES CXX C  VERSION ${MAJOR}.${MINOR}.${PATCH})

# User-settings
set(SERIOUS_PROTON_DIR "../SeriousProton" CACHE PATH "Path to SeriousProton")

message(STATUS "EmptyEpsilon Version = ${PROJECT_VERSION}")

# Dependencies

# Setup OpenGl
if(NOT ANDROID)
    find_package(OpenGL REQUIRED)
endif()

# SeriousProton
# Use SP provided json library.
set(SERIOUSPROTON_WITH_JSON ON CACHE BOOL "" FORCE)
add_subdirectory("${SERIOUS_PROTON_DIR}" "${PROJECT_BINARY_DIR}/SeriousProton" EXCLUDE_FROM_ALL)

message(STATUS "Crash Logger is: ${ENABLE_CRASH_LOGGER}")

set(EXTERNALS_DIR "${PROJECT_BINARY_DIR}/externals")
set(DOWNLOADS_DIR "${PROJECT_BINARY_DIR}/downloads")
file(MAKE_DIRECTORY "${EXTERNAL_DIR}" "${DOWNLOADS_DIR}")

# Discord
if(WIN32)
  set(DISCORD_ARCH "x86_64")
  if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    set(DISCORD_ARCH "x86")
  endif()
  set(DISCORD_LIB_PATH "${EXTERNALS_DIR}/discord/lib/${DISCORD_ARCH}")
  file(MAKE_DIRECTORY "${DISCORD_LIB_PATH}")
  if(NOT EXISTS "${DISCORD_LIB_PATH}/discord_game_sdk.dll.lib")
    set(DISCORD_GAME_SDK "${DOWNLOADS_DIR}/discord_game_sdk.zip")
    file(DOWNLOAD "https://dl-game-sdk.discordapp.net/latest/discord_game_sdk.zip" "${DISCORD_GAME_SDK}" TIMEOUT 60 TLS_VERIFY ON)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf "${DISCORD_GAME_SDK}" WORKING_DIRECTORY "${EXTERNALS_DIR}/discord")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      # Discord uses Windows.h (capital W) and that does not play nice when cross-compiling.
      # we want to patch with a lowercase windows.h
      message(STATUS "Patching discord_game_sdk.h, using a lowercase Windows.h (cross-compilation compatibility)")
      execute_process(COMMAND sed -i "s/<Windows.h>/<windows.h>/g" c/discord_game_sdk.h WORKING_DIRECTORY "${EXTERNALS_DIR}/discord")
    endif()
  endif()
  
  add_library(discord SHARED IMPORTED)
  set_target_properties(discord PROPERTIES
    IMPORTED_LOCATION "${DISCORD_LIB_PATH}/discord_game_sdk.dll"
    IMPORTED_IMPLIB "${DISCORD_LIB_PATH}/discord_game_sdk.dll.lib"
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERNALS_DIR}/discord/c/"
  )
endif()

# GLM
set(GLM_BASE_PATH "${EXTERNALS_DIR}")

if(NOT EXISTS "${GLM_BASE_PATH}/glm/CMakeLists.txt")
  set(GLM_ZIP "${DOWNLOADS_DIR}/glm.zip")
  file(DOWNLOAD "https://github.com/g-truc/glm/releases/download/0.9.9.8/glm-0.9.9.8.zip" "${GLM_ZIP}" TIMEOUT 60 TLS_VERIFY ON)

  file(MAKE_DIRECTORY "${GLM_BASE_PATH}/glm")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf "${GLM_ZIP}" WORKING_DIRECTORY "${GLM_BASE_PATH}")
endif()

add_subdirectory("${GLM_BASE_PATH}/glm" "${PROJECT_BINARY_DIR}/glm" EXCLUDE_FROM_ALL)


# Set minimum target macOS version
if(APPLE)
    set(MACOSX_DEPLOYMENT_TARGET "10.10")
endif()


set(SOURCES
    src/main.cpp
    src/threatLevelEstimate.cpp
    src/preferenceManager.cpp
    src/pathPlanner.cpp
    src/epsilonServer.cpp
    src/particleEffect.cpp
    src/mouseCalibrator.cpp
    src/httpScriptAccess.cpp
    src/modelInfo.cpp
    src/packResourceProvider.cpp
    src/scienceDatabase.cpp
    src/commsScriptInterface.cpp
    src/modelData.cpp
    src/gameGlobalInfo.cpp
    src/GMActions.cpp
    src/script.cpp
    src/playerInfo.cpp
    src/gameStateLogger.cpp
    src/shipTemplate.cpp
    src/beamTemplate.cpp
    src/missileWeaponData.cpp
    src/factionInfo.cpp
    src/mesh.cpp
    src/scenarioInfo.cpp
    src/repairCrew.cpp
    src/GMScriptCallback.cpp
    src/GMMessage.cpp
    src/tutorialGame.cpp
    src/scriptDataStorage.cpp
    src/glObjects.cpp
    src/menus/joinServerMenu.cpp
    src/menus/serverBrowseMenu.cpp
    src/menus/mainMenus.cpp
    src/menus/serverCreationScreen.cpp
    src/menus/tutorialMenu.cpp
    src/menus/optionsMenu.cpp
    src/menus/shipSelectionScreen.cpp
    src/menus/autoConnectScreen.cpp
    src/menus/hotkeyMenu.cpp
    src/screens/cinematicViewScreen.cpp
    src/screens/crewStationScreen.cpp
    src/screens/topDownScreen.cpp
    src/screens/windowScreen.cpp
    src/screens/mainScreen.cpp
    src/screens/spectatorScreen.cpp
    src/screens/crew4/operationsScreen.cpp
    src/screens/crew4/engineeringAdvancedScreen.cpp
    src/screens/crew4/tacticalScreen.cpp
    src/screens/crew6/engineeringScreen.cpp
    src/screens/crew6/scienceScreen.cpp
    src/screens/crew6/relayScreen.cpp
    src/screens/crew6/weaponsScreen.cpp
    src/screens/crew6/helmsScreen.cpp
    src/screens/crew1/singlePilotScreen.cpp
    src/screens/extra/damcon.cpp
    src/screens/extra/powerManagement.cpp
    src/screens/extra/databaseScreen.cpp
    src/screens/extra/commsScreen.cpp
    src/screens/extra/shipLogScreen.cpp
    src/screens/gm/gameMasterScreen.cpp
    src/screens/gm/objectCreationView.cpp
    src/screens/gm/globalMessageEntryView.cpp
    src/screens/gm/chatDialog.cpp
    src/screens/gm/tweak.cpp
    src/screenComponents/aimLock.cpp
    src/screenComponents/alertOverlay.cpp
    src/screenComponents/helpOverlay.cpp
    src/screenComponents/missileTubeControls.cpp
    src/screenComponents/selfDestructIndicator.cpp
    src/screenComponents/viewport3d.cpp
    src/screenComponents/viewportMainScreen.cpp
    src/screenComponents/selfDestructEntry.cpp
    src/screenComponents/dockingButton.cpp
    src/screenComponents/shieldsEnableButton.cpp
    src/screenComponents/selfDestructButton.cpp
    src/screenComponents/shieldFreqencySelect.cpp
    src/screenComponents/jumpControls.cpp
    src/screenComponents/impulseControls.cpp
    src/screenComponents/frequencyCurve.cpp
    src/screenComponents/noiseOverlay.cpp
    src/screenComponents/powerDamageIndicator.cpp
    src/screenComponents/beamTargetSelector.cpp
    src/screenComponents/shipInternalView.cpp
    src/screenComponents/beamFrequencySelector.cpp
    src/screenComponents/radarView.cpp
    src/screenComponents/rawScannerDataRadarOverlay.cpp
    src/screenComponents/scanTargetButton.cpp
    src/screenComponents/snapSlider.cpp
    src/screenComponents/indicatorOverlays.cpp
    src/screenComponents/openCommsButton.cpp
    src/screenComponents/combatManeuver.cpp
    src/screenComponents/rotatingModelView.cpp
    src/screenComponents/shipDestroyedPopup.cpp
    src/screenComponents/warpControls.cpp
    src/screenComponents/targetsContainer.cpp
    src/screenComponents/globalMessage.cpp
    src/screenComponents/commsOverlay.cpp
    src/screenComponents/jumpIndicator.cpp
    src/screenComponents/scanningDialog.cpp
    src/screenComponents/signalQualityIndicator.cpp
    src/screenComponents/mainScreenControls.cpp
    src/screenComponents/databaseView.cpp
    src/screenComponents/shipsLogControl.cpp
    src/screenComponents/onScreenKeyboard.cpp
    src/screenComponents/hackingDialog.cpp
    src/screenComponents/customShipFunctions.cpp
    src/screenComponents/scrollingBanner.cpp
    src/screenComponents/lightsOut.cpp
    src/screenComponents/miniGame.cpp
    src/screenComponents/mineSweeper.cpp
    src/screenComponents/impulseSound.cpp
    src/gui/colorConfig.cpp
    src/gui/hotkeyBinder.cpp
    src/gui/hotkeyConfig.cpp
    src/gui/joystickConfig.cpp
    src/gui/mouseRenderer.cpp
    src/gui/scriptError.cpp
    src/gui/gui2_slider.cpp
    src/gui/gui2_togglebutton.cpp
    src/gui/gui2_arrow.cpp
    src/gui/gui2_selector.cpp
    src/gui/gui2_canvas.cpp
    src/gui/gui2_rotationdial.cpp
    src/gui/gui2_textentry.cpp
    src/gui/gui2_label.cpp
    src/gui/gui2_image.cpp
    src/gui/gui2_autolayout.cpp
    src/gui/gui2_arrowbutton.cpp
    src/gui/gui2_entrylist.cpp
    src/gui/gui2_progressbar.cpp
    src/gui/gui2_progressslider.cpp
    src/gui/gui2_scrolltext.cpp
    src/gui/gui2_advancedscrolltext.cpp
    src/gui/gui2_button.cpp
    src/gui/gui2_resizabledialog.cpp
    src/gui/debugRenderer.cpp
    src/gui/gui2_element.cpp
    src/gui/gui2_keyvaluedisplay.cpp
    src/gui/gui2_listbox.cpp
    src/gui/gui2_scrollbar.cpp
    src/gui/gui2_container.cpp
    src/gui/gui2_panel.cpp
    src/gui/gui2_overlay.cpp
    src/spaceObjects/missiles/missileWeapon.cpp
    src/spaceObjects/missiles/EMPMissile.cpp
    src/spaceObjects/missiles/homingMissile.cpp
    src/spaceObjects/missiles/hvli.cpp
    src/spaceObjects/missiles/nuke.cpp
    src/spaceObjects/spaceStation.cpp
    src/spaceObjects/spaceship.cpp
    src/spaceObjects/wormHole.cpp
    src/spaceObjects/spaceObject.cpp
    src/spaceObjects/nebula.cpp
    src/spaceObjects/explosionEffect.cpp
    src/spaceObjects/cpuShip.cpp
    src/spaceObjects/asteroid.cpp
    src/spaceObjects/mine.cpp
    src/spaceObjects/blackHole.cpp
    src/spaceObjects/playerSpaceship.cpp
    src/spaceObjects/beamEffect.cpp
    src/spaceObjects/electricExplosionEffect.cpp
    src/spaceObjects/supplyDrop.cpp
    src/spaceObjects/warpJammer.cpp
    src/spaceObjects/scanProbe.cpp
    src/spaceObjects/artifact.cpp
    src/spaceObjects/shipTemplateBasedObject.cpp
    src/spaceObjects/planet.cpp
    src/spaceObjects/zone.cpp
    src/spaceObjects/spaceshipParts/beamWeapon.cpp
    src/spaceObjects/spaceshipParts/weaponTube.cpp
    src/ai/fighterAI.cpp
    src/ai/ai.cpp
    src/ai/aiFactory.cpp
    src/ai/evasionAI.cpp
    src/ai/missileVolleyAI.cpp
    src/hardware/hardwareController.cpp
    src/hardware/hardwareMappingEffects.cpp
    src/hardware/serialDriver.cpp
    src/hardware/devices/dmx512SerialDevice.cpp
    src/hardware/devices/enttecDMXProDevice.cpp
    src/hardware/devices/sACNDMXDevice.cpp
    src/hardware/devices/uDMXDevice.cpp
    src/hardware/devices/virtualOutputDevice.cpp
    src/hardware/devices/philipsHueDevice.cpp
)

if (WIN32)
  list(APPEND SOURCES EmptyEpsilon.rc src/discord.cpp)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED ${SOURCES})
else()
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SOURCES})
endif()

target_compile_definitions(${PROJECT_NAME}
    PUBLIC
        WINDOW_TITLE="${PROJECT_NAME}"
        VERSION_NUMBER=${PROJECT_VERSION_MAJOR}${PROJECT_VERSION_MINOR}${PROJECT_VERSION_PATCH}

        # Set RESOURCE_BASE_DIR on Unix so the built binary is able to find resources
        $<$<BOOL:${UNIX}>:RESOURCE_BASE_DIR="${CMAKE_INSTALL_PREFIX}/share/emptyepsilon/">
        $<$<BOOL:${CONFIG_DIR}>:CONFIG_DIR="${CONFIG_DIR}">
        $<$<NOT:$<BOOL:${CONFIG_DIR}>>:CONFIG_DIR="${CMAKE_INSTALL_PREFIX}/share/emptyepsilon/">
)

target_compile_definitions(seriousproton
    PUBLIC
        WINDOW_TITLE="${PROJECT_NAME}"
        VERSION_NUMBER=${PROJECT_VERSION_MAJOR}${PROJECT_VERSION_MINOR}${PROJECT_VERSION_PATCH}

        # Set RESOURCE_BASE_DIR on Unix so the built binary is able to find resources
        $<$<BOOL:${UNIX}>:RESOURCE_BASE_DIR="${CMAKE_INSTALL_PREFIX}/share/emptyepsilon/">
        $<$<BOOL:${CONFIG_DIR}>:CONFIG_DIR="${CONFIG_DIR}">
        $<$<NOT:$<BOOL:${CONFIG_DIR}>>:CONFIG_DIR="${CMAKE_INSTALL_PREFIX}/share/emptyepsilon/">
)

# install resources, scripts, and packs to app bundle instead of system dir.
if(APPLE)
    set(CMAKE_INSTALL_PREFIX "./")
endif()

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)

add_library(opengl INTERFACE)
target_link_libraries(opengl
  INTERFACE
  "$<$<BOOL:${ANDROID}>:GLESv1_CM;EGL>"
  "$<$<NOT:$<BOOL:${ANDROID}>>:OpenGL::GL>"
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        seriousproton glm::glm opengl
        "$<$<BOOL:${ANDROID}>:log;android>"
        "$<$<BOOL:${WIN32}>:iphlpapi;discord>"
        "$<$<PLATFORM_ID:Darwin>:-framework Foundation>"
        
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/osx/MacOSXBundleInfo.plist.in
        MACOSX_BUNDLE_ICON_FILE "${PROJECT_NAME}.icns")

if(ANDROID)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--whole-archive ${SFML_INSTALL_PATH}/lib/${ANDROID_ABI}/libsfml-main.a -Wl,--no-whole-archive")
endif()

include(InstallRequiredSystemLibraries)


set(EE_RESOURCES resources scripts packs)
if(WIN32)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION .)
    install(DIRECTORY ${EE_RESOURCES} DESTINATION .)

    get_target_property(DISCORD_DLL discord IMPORTED_LOCATION)

    install(FILES "${DISCORD_DLL}" DESTINATION .)

    
    if(MSVC)
      # Not all configuration emit a pdb (ie Release), make this optional.
      install(FILES "$<TARGET_PDB_FILE:${PROJECT_NAME}>" DESTINATION . OPTIONAL)
    endif()
elseif(APPLE)
  install(FILES logo.icns DESTINATION "${PROJECT_NAME}.app/Contents/Resources" RENAME "${PROJECT_NAME}.icns")
  install(DIRECTORY ${EE_RESOURCES} DESTINATION "${PROJECT_NAME}.app/Contents/Resources")
elseif(ANDROID)
  android_apk(EmptyEpsilon)
else()
    include(GNUInstallDirs)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
    install(DIRECTORY ${EE_RESOURCES} DESTINATION "${CMAKE_INSTALL_DATADIR}")
endif()

find_package(PythonInterp)
if(PYTHONINTERP_FOUND)
    set(SCRIPT_REFERENCE_HTML "${PROJECT_BINARY_DIR}/script_reference.html")
    add_custom_command(
        OUTPUT "${SCRIPT_REFERENCE_HTML}"
        COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/compile_script_docs.py "${SCRIPT_REFERENCE_HTML}"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Building script reference documentation.")
    add_custom_target(script_reference ALL DEPENDS "${SCRIPT_REFERENCE_HTML}")
  
  # Matches install logic above.
  if(WIN32)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION .)
  elseif(APPLE)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "${PROJECT_NAME}.app/Contents/Resources")
  elseif(NOT ANDROID)
    # DOCDIR already has PROJECT_NAME (EmptyEpsilon) appended (from CMake docs)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "${CMAKE_INSTALL_DOCDIR}")
  endif()
endif()

add_custom_target(update_locale
    COMMAND sed -i "/^#: /d" resources/locale/en.po
    COMMAND sed -i "/^#: /d" resources/locale/tutorial.en.po
    COMMAND xgettext --keyword=tr:1c,2 --keyword=tr:1 --keyword=trMark:1c,2 --keyword=trMark:1 --omit-header -j -d resources/locale/en ${SOURCES}
    COMMAND xgettext --keyword=_:1c,2 --keyword=_:1 --omit-header -j -d resources/locale/en scripts/shipTemplates_*.lua scripts/comms_ship.lua scripts/comms_station.lua scripts/comms_supply_drop.lua scripts/factionInfo.lua scripts/science_db.lua
    COMMAND xgettext --keyword=_:1c,2 --keyword=_:1 --omit-header -j -d resources/locale/tutorial.en scripts/tutorial_*.lua
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

set(CPACK_PACKAGE_EXECUTABLES ${PROJECT_NAME})
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_CONTACT "https://github.com/daid/")
if(NOT DEFINED CPACK_GENERATOR)
  if(WIN32)
    set(CPACK_GENERATOR "ZIP")
  elseif(UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libsfml-dev")
  endif()
endif()

# Setup install targets:
# - For EE, we use everything that's been provided with install command.
# - For SP, we use only the things having the 'runtime' component (ie shared libs).
set(CPACK_INSTALL_CMAKE_PROJECTS
    "${PROJECT_BINARY_DIR};${PROJECT_NAME};ALL;/"
    "${PROJECT_BINARY_DIR}/SeriousProton;SeriousProton;runtime;/"
)

include(CPack)
