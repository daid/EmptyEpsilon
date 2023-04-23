# Set minimum target macOS version: https://cmake.org/cmake/help/v3.8/variable/CMAKE_OSX_DEPLOYMENT_TARGET.html#variable:CMAKE_OSX_DEPLOYMENT_TARGET
# SDL2 targets 10.5, however EE targets C++17 features only available in 10.15+ (Catalina, June 2019).
# Must be first!
if(APPLE)
  if(NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
    set(ENV{MACOSX_DEPLOYMENT_TARGET} "10.15")
  endif()
  
  message(STATUS "Mac deployment target is: $ENV{MACOSX_DEPLOYMENT_TARGET}")
endif()

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

include(GNUInstallDirs)

# Defaults
set(WITH_DISCORD_DEFAULT OFF)
if(WIN32)
  set(WITH_DISCORD_DEFAULT ON)
endif()

# User-settings
set(SERIOUS_PROTON_DIR "../SeriousProton" CACHE PATH "Path to SeriousProton")
if(NOT ANDROID)
    option(WITH_DISCORD "Build with Discord support" ${WITH_DISCORD_DEFAULT})
else()
    set(WITH_DISCORD OFF)
    option(APK_WITH_PACKS "Build APK with pack files (3D assets)" ON)
endif()

message(STATUS "EmptyEpsilon Version = ${PROJECT_VERSION}")

# Enable colored output with Ninja
if((CMAKE_GENERATOR MATCHES "Ninja") AND (CMAKE_CXX_COMPILER_ID MATCHES "GNU"))
    add_compile_options (-fdiagnostics-color)
endif()

# Dependencies

# SeriousProton
add_subdirectory("${SERIOUS_PROTON_DIR}" "${PROJECT_BINARY_DIR}/SeriousProton" EXCLUDE_FROM_ALL)

set(EXTERNALS_DIR "${PROJECT_BINARY_DIR}/externals")
set(DOWNLOADS_DIR "${PROJECT_BINARY_DIR}/downloads")
file(MAKE_DIRECTORY "${EXTERNAL_DIR}" "${DOWNLOADS_DIR}")

# Discord
if(WITH_DISCORD)
  set(DISCORD_ARCH "x86_64")
  if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    set(DISCORD_ARCH "x86")
  endif()
  set(DISCORD_INCLUDE_PATH "${EXTERNALS_DIR}/discord/c")
  set(DISCORD_LIB_PATH "${EXTERNALS_DIR}/discord/lib/${DISCORD_ARCH}")
  file(MAKE_DIRECTORY "${DISCORD_INCLUDE_PATH}")
  if(NOT EXISTS "${DISCORD_INCLUDE_PATH}/discord_game_sdk.h")
    set(DISCORD_GAME_SDK "${DOWNLOADS_DIR}/discord_game_sdk.zip")
    file(DOWNLOAD "https://dl-game-sdk.discordapp.net/latest/discord_game_sdk.zip" "${DISCORD_GAME_SDK}" TIMEOUT 60 TLS_VERIFY ON)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf "${DISCORD_GAME_SDK}" WORKING_DIRECTORY "${EXTERNALS_DIR}/discord")
    if(WIN32 AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      # Discord uses Windows.h (capital W) and that does not play nice when cross-compiling.
      # we want to patch with a lowercase windows.h
      message(STATUS "Patching discord_game_sdk.h, using a lowercase Windows.h (cross-compilation compatibility)")
      execute_process(COMMAND sed -i "s/<Windows.h>/<windows.h>/g" c/discord_game_sdk.h WORKING_DIRECTORY "${EXTERNALS_DIR}/discord")
    endif()
  endif()
  add_library(discord_h INTERFACE IMPORTED)
  set_target_properties(discord_h PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${DISCORD_INCLUDE_PATH}"  
  )
  add_library(discord SHARED IMPORTED)
  set_target_properties(discord PROPERTIES
    IMPORTED_LOCATION "${DISCORD_LIB_PATH}/discord_game_sdk${CMAKE_SHARED_LIBRARY_SUFFIX}"
  )
  
  if (WIN32)
    set_target_properties(discord PROPERTIES
      IMPORTED_IMPLIB "${DISCORD_LIB_PATH}/discord_game_sdk.dll.lib"
    )
  endif()

  target_link_libraries(discord INTERFACE discord_h)
endif()

# Meshoptimizer
set(MESHOPTIMIZER_VERSION 0.16)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.11)
  include(FetchContent)
  FetchContent_Declare(
    meshoptimizer
    GIT_REPOSITORY https://github.com/zeux/meshoptimizer/
    GIT_TAG "v${MESHOPTIMIZER_VERSION}"
  )
  FetchContent_GetProperties(meshoptimizer)
else()
  # Poor man's FetchContent.
  set(MESHOPTIMIZER_BASE_PATH "${EXTERNALS_DIR}")
  set(meshoptimizer_POPULATED FALSE)
  if(NOT EXISTS "${MESHOPTIMIZER_BASE_PATH}/meshoptimizer/CMakeLists.txt")
    set(MESHOPTIMIZER_ZIP "${DOWNLOADS_DIR}/meshoptimizer.zip")
    file(DOWNLOAD "https://github.com/zeux/meshoptimizer/archive/refs/tags/v${MESHOPTIMIZER_VERSION}.zip" "${MESHOPTIMIZER_ZIP}" TIMEOUT 60 TLS_VERIFY ON)

    execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf "${MESHOPTIMIZER_ZIP}" WORKING_DIRECTORY "${MESHOPTIMIZER_BASE_PATH}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E rename "meshoptimizer-${MESHOPTIMIZER_VERSION}" meshoptimizer WORKING_DIRECTORY "${MESHOPTIMIZER_BASE_PATH}")
  endif()

  set(meshoptimizer_SOURCE_DIR "${MESHOPTIMIZER_BASE_PATH}/meshoptimizer")
  set(meshoptimizer_BINARY_DIR "${PROJECT_BINARY_DIR}/externals/meshoptimizer")
endif()

if(NOT meshoptimizer_POPULATED)
  if(COMMAND FetchContent_Populate)
    FetchContent_Populate(meshoptimizer)
  endif()
  add_subdirectory(${meshoptimizer_SOURCE_DIR} ${meshoptimizer_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

set(GUI_LIB_SOURCES
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
    src/gui/theme.cpp
    src/gui/layout/layout.cpp
    src/gui/layout/horizontal.cpp
    src/gui/layout/vertical.cpp

    src/gui/colorConfig.h
    src/gui/debugRenderer.h
    src/gui/gui2_advancedscrolltext.h
    src/gui/gui2_arrowbutton.h
    src/gui/gui2_arrow.h
    src/gui/gui2_button.h
    src/gui/gui2_canvas.h
    src/gui/gui2_container.h
    src/gui/gui2_element.h
    src/gui/gui2_entrylist.h
    src/gui/gui2_image.h
    src/gui/gui2_keyvaluedisplay.h
    src/gui/gui2_label.h
    src/gui/gui2_listbox.h
    src/gui/gui2_overlay.h
    src/gui/gui2_panel.h
    src/gui/gui2_progressbar.h
    src/gui/gui2_progressslider.h
    src/gui/gui2_resizabledialog.h
    src/gui/gui2_rotationdial.h
    src/gui/gui2_scrollbar.h
    src/gui/gui2_scrolltext.h
    src/gui/gui2_selector.h
    src/gui/gui2_slider.h
    src/gui/gui2_textentry.h
    src/gui/gui2_togglebutton.h
    src/gui/theme.h
    src/gui/layout/layout.h
    src/gui/layout/horizontal.h
    src/gui/layout/vertical.h
    src/gui/hotkeyBinder.h
    src/gui/hotkeyConfig.h
    src/gui/joystickConfig.h
    src/gui/mouseRenderer.h
    src/gui/scriptError.h
)

set(MAIN_SOURCES
    src/main.cpp
    src/threatLevelEstimate.cpp
    src/preferenceManager.cpp
    src/epsilonServer.cpp
    src/particleEffect.cpp
    src/httpScriptAccess.cpp
    src/modelInfo.cpp
    src/packResourceProvider.cpp
    src/scienceDatabase.cpp
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
    src/GMScriptCallback.cpp
    src/GMMessage.cpp
    src/tutorialGame.cpp
    src/scriptDataStorage.cpp
    src/shaderRegistry.cpp
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
    src/screenComponents/alertLevelButton.cpp
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
    src/components/faction.h
    src/components/faction.cpp
    src/components/radar.h
    src/components/hull.h
    src/components/rendering.h
    src/components/docking.h
    src/components/coolant.h
    src/components/shipsystem.h
    src/components/shipsystem.cpp
    src/components/impulse.h
    src/components/maneuveringthrusters.h
    src/components/warpdrive.h
    src/components/jumpdrive.h
    src/components/reactor.h
    src/components/shields.h
    src/components/shields.cpp
    src/components/beamweapon.h
    src/components/target.h
    src/components/missiletubes.h
    src/components/selfdestruct.h
    src/components/player.h
    src/components/player.cpp
    src/components/pickup.h
    src/components/spin.h
    src/components/rendering.h
    src/components/name.h
    src/components/customshipfunction.h
    src/components/shiplog.h
    src/components/shiplog.cpp
    src/components/comms.h
    src/components/scanning.h
    src/components/scanning.cpp
    src/components/internalrooms.h
    src/components/internalrooms.cpp
    src/components/probe.h
    src/components/hacking.h
    src/components/ai.h
    src/components/radarblock.h
    src/components/gravity.h
    src/components/avoidobject.h
    src/components/sfx.h
    src/components/missile.h
    src/systems/ai.h
    src/systems/ai.cpp
    src/systems/docking.h
    src/systems/docking.cpp
    src/systems/shipsystemssystem.h
    src/systems/shipsystemssystem.cpp
    src/systems/coolantsystem.h
    src/systems/coolantsystem.cpp
    src/systems/energysystem.h
    src/systems/energysystem.cpp
    src/systems/impulse.h
    src/systems/impulse.cpp
    src/systems/maneuvering.h
    src/systems/maneuvering.cpp
    src/systems/beamweapon.h
    src/systems/beamweapon.cpp
    src/systems/missilesystem.h
    src/systems/missilesystem.cpp
    src/systems/warpsystem.h
    src/systems/warpsystem.cpp
    src/systems/jumpsystem.h
    src/systems/jumpsystem.cpp
    src/systems/shieldsystem.h
    src/systems/shieldsystem.cpp
    src/systems/damage.h
    src/systems/damage.cpp
    src/systems/selfdestruct.h
    src/systems/selfdestruct.cpp
    src/systems/pickup.h
    src/systems/pickup.cpp
    src/systems/basicmovement.h
    src/systems/basicmovement.cpp
    src/systems/gravity.h
    src/systems/gravity.cpp
    src/systems/comms.h
    src/systems/comms.cpp
    src/systems/radarblock.h
    src/systems/radarblock.cpp
    src/systems/internalcrew.h
    src/systems/internalcrew.cpp
    src/systems/pathfinding.h
    src/systems/pathfinding.cpp
    src/systems/rendering.h
    src/systems/rendering.cpp
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

    src/ai/aiFactory.h
    src/ai/ai.h
    src/ai/evasionAI.h
    src/ai/fighterAI.h
    src/ai/missileVolleyAI.h
    src/beamTemplate.h
    src/epsilonServer.h
    src/factionInfo.h
    src/featureDefs.h
    src/gameGlobalInfo.h
    src/gameStateLogger.h
    src/glObjects.h
    src/GMActions.h
    src/GMMessage.h
    src/GMScriptCallback.h
    src/hardware/devices/dmx512SerialDevice.h
    src/hardware/devices/enttecDMXProDevice.h
    src/hardware/devices/philipsHueDevice.h
    src/hardware/devices/sACNDMXDevice.h
    src/hardware/devices/uDMXDevice.h
    src/hardware/devices/virtualOutputDevice.h
    src/hardware/hardwareController.h
    src/hardware/hardwareMappingEffects.h
    src/hardware/hardwareOutputDevice.h
    src/hardware/serialDriver.h
    src/httpScriptAccess.h
    src/main.h
    src/math/centerOfMass.h
    src/math/triangulate.h
    src/menus/autoConnectScreen.h
    src/menus/hotkeyMenu.h
    src/menus/joinServerMenu.h
    src/menus/mainMenus.h
    src/menus/optionsMenu.h
    src/menus/serverBrowseMenu.h
    src/menus/serverCreationScreen.h
    src/menus/shipSelectionScreen.h
    src/menus/tutorialMenu.h
    src/mesh.h
    src/missileWeaponData.h
    src/modelData.h
    src/modelInfo.h
    src/packResourceProvider.h
    src/particleEffect.h
    src/playerInfo.h
    src/preferenceManager.h
    src/scenarioInfo.h
    src/scienceDatabase.h
    src/screenComponents/aimLock.h
    src/screenComponents/alertLevelButton.h
    src/screenComponents/alertOverlay.h
    src/screenComponents/beamFrequencySelector.h
    src/screenComponents/beamTargetSelector.h
    src/screenComponents/combatManeuver.h
    src/screenComponents/commsOverlay.h
    src/screenComponents/customShipFunctions.h
    src/screenComponents/databaseView.h
    src/screenComponents/dockingButton.h
    src/screenComponents/frequencyCurve.h
    src/screenComponents/globalMessage.h
    src/screenComponents/hackingDialog.h
    src/screenComponents/helpOverlay.h
    src/screenComponents/impulseControls.h
    src/screenComponents/impulseSound.h
    src/screenComponents/indicatorOverlays.h
    src/screenComponents/jumpControls.h
    src/screenComponents/jumpIndicator.h
    src/screenComponents/lightsOut.h
    src/screenComponents/mainScreenControls.h
    src/screenComponents/mineSweeper.h
    src/screenComponents/miniGame.h
    src/screenComponents/missileTubeControls.h
    src/screenComponents/noiseOverlay.h
    src/screenComponents/onScreenKeyboard.h
    src/screenComponents/openCommsButton.h
    src/screenComponents/powerDamageIndicator.h
    src/screenComponents/radarView.h
    src/screenComponents/rawScannerDataRadarOverlay.h
    src/screenComponents/rotatingModelView.h
    src/screenComponents/scanningDialog.h
    src/screenComponents/scanTargetButton.h
    src/screenComponents/scrollingBanner.h
    src/screenComponents/selfDestructButton.h
    src/screenComponents/selfDestructEntry.h
    src/screenComponents/selfDestructIndicator.h
    src/screenComponents/shieldFreqencySelect.h
    src/screenComponents/shieldsEnableButton.h
    src/screenComponents/shipDestroyedPopup.h
    src/screenComponents/shipInternalView.h
    src/screenComponents/shipsLogControl.h
    src/screenComponents/signalQualityIndicator.h
    src/screenComponents/snapSlider.h
    src/screenComponents/targetsContainer.h
    src/screenComponents/viewport3d.h
    src/screenComponents/viewportMainScreen.h
    src/screenComponents/warpControls.h
    src/screens/cinematicViewScreen.h
    src/screens/crew1/singlePilotScreen.h
    src/screens/crew4/engineeringAdvancedScreen.h
    src/screens/crew4/operationsScreen.h
    src/screens/crew4/tacticalScreen.h
    src/screens/crew6/engineeringScreen.h
    src/screens/crew6/helmsScreen.h
    src/screens/crew6/relayScreen.h
    src/screens/crew6/scienceScreen.h
    src/screens/crew6/weaponsScreen.h
    src/screens/crewStationScreen.h
    src/screens/extra/commsScreen.h
    src/screens/extra/damcon.h
    src/screens/extra/databaseScreen.h
    src/screens/extra/powerManagement.h
    src/screens/extra/shipLogScreen.h
    src/screens/gm/chatDialog.h
    src/screens/gm/gameMasterScreen.h
    src/screens/gm/globalMessageEntryView.h
    src/screens/gm/objectCreationView.h
    src/screens/gm/tweak.h
    src/screens/mainScreen.h
    src/screens/spectatorScreen.h
    src/screens/topDownScreen.h
    src/screens/windowScreen.h
    src/script.h
    src/shaderRegistry.h
    src/shipTemplate.h
    src/spaceObjects/artifact.h
    src/spaceObjects/asteroid.h
    src/spaceObjects/beamEffect.h
    src/spaceObjects/blackHole.h
    src/spaceObjects/cpuShip.h
    src/spaceObjects/electricExplosionEffect.h
    src/spaceObjects/explosionEffect.h
    src/spaceObjects/mine.h
    src/spaceObjects/nebula.h
    src/spaceObjects/planet.h
    src/spaceObjects/playerSpaceship.h
    src/spaceObjects/scanProbe.h
    src/spaceObjects/shipTemplateBasedObject.h
    src/spaceObjects/spaceObject.h
    src/spaceObjects/spaceship.h
    src/spaceObjects/spaceStation.h
    src/spaceObjects/supplyDrop.h
    src/spaceObjects/warpJammer.h
    src/spaceObjects/wormHole.h
    src/spaceObjects/zone.h
    src/threatLevelEstimate.h
    src/tutorialGame.h
)

if (WITH_DISCORD)
  list(APPEND MAIN_SOURCES src/discord.cpp src/discord.h)
endif()
if (STEAMSDK)
  list(APPEND MAIN_SOURCES src/steamrichpresence.cpp src/steamrichpresence.h)
endif()

if (WIN32)
  list(APPEND MAIN_SOURCES EmptyEpsilon.rc)
endif()

# Config header.
configure_file(cmake/config.h.in include/config.h)

if (SHARED_SP)
    set(EE_LIB_TYPE SHARED)
else()
    set(EE_LIB_TYPE STATIC)
endif()

add_library(EE_GuiLIB ${EE_LIB_TYPE} ${GUI_LIB_SOURCES})
target_link_libraries(EE_GuiLIB PUBLIC seriousproton meshoptimizer)
target_include_directories(EE_GuiLIB PUBLIC "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src;${CMAKE_CURRENT_BINARY_DIR}/include>")

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED ${MAIN_SOURCES})
else()
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${MAIN_SOURCES})
endif()

target_compile_definitions(${PROJECT_NAME}
    PUBLIC
        # Set RESOURCE_BASE_DIR on Unix so the built binary is able to find resources
        $<$<AND:$<BOOL:${UNIX}>,$<NOT:$<BOOL:${STEAMSDK}>>>:RESOURCE_BASE_DIR="${CMAKE_INSTALL_FULL_DATADIR}/emptyepsilon/">
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src;${CMAKE_CURRENT_BINARY_DIR}/include>"
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        seriousproton meshoptimizer EE_GuiLIB
        "$<$<BOOL:${ANDROID}>:log;android>"
        "$<$<BOOL:${WITH_DISCORD}>:discord_h>"
        "$<$<PLATFORM_ID:Darwin>:-framework Foundation>"
)
if(WIN32)
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_link_libraries(${PROJECT_NAME} PUBLIC "-mconsole")
    endif()
endif()

set_target_properties(${PROJECT_NAME}
    PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/osx/MacOSXBundleInfo.plist.in
        MACOSX_BUNDLE_ICON_FILE "${PROJECT_NAME}.icns")

include(InstallRequiredSystemLibraries)


set(EE_RESOURCES resources scripts packs)
if(WIN32 OR STEAMSDK)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION .)
    install(DIRECTORY ${EE_RESOURCES} DESTINATION .)

    if(MSVC)
      # Not all configuration emit a pdb (ie Release), make this optional.
      install(FILES "$<TARGET_PDB_FILE:${PROJECT_NAME}>" DESTINATION . OPTIONAL)
    endif()
elseif(APPLE)
  install(FILES logo.icns DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources" RENAME "${PROJECT_NAME}.icns")
  install(DIRECTORY ${EE_RESOURCES} DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources")
elseif(ANDROID)
  android_apk(EmptyEpsilon ${APK_WITH_PACKS})
else()
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
    install(DIRECTORY ${EE_RESOURCES} DESTINATION "${CMAKE_INSTALL_DATADIR}/emptyepsilon")
endif()

if(WITH_DISCORD)
    set(discord_install_prefix)
    if(WIN32)
        set(discord_install_prefix ".")
    elseif(APPLE)
        set(discord_install_prefix "${PROJECT_NAME}.app/Contents/Resources")
    else()
        set(discord_install_prefix "${CMAKE_INSTALL_DATADIR}/emptyepsilon")
    endif()

    install(PROGRAMS "$<TARGET_PROPERTY:discord,IMPORTED_LOCATION>" DESTINATION "${discord_install_prefix}/plugins")
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
  if(WIN32 OR STEAMSDK)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION . OPTIONAL)
  elseif(APPLE)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources" OPTIONAL)
  elseif(NOT ANDROID)
    # DOCDIR already has PROJECT_NAME (EmptyEpsilon) appended (from CMake docs)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "${CMAKE_INSTALL_DOCDIR}" OPTIONAL)
  endif()
endif()

add_custom_target(update_locale
    COMMAND xgettext --keyword=tr:1c,2 --keyword=tr:1 --keyword=trMark:1c,2 --keyword=trMark:1 --omit-header -d resources/locale/main.en ${MAIN_SOURCES} ${GUI_LIB_SOURCES}
    COMMAND python3 update_locale.py
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

if(APPLE)
  # This *MUST* be the last install target.
  # Otherwise, for some messed up reason,
  # other install targets will not be accounted for when creating a DMG bundle.
  install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION . RUNTIME DESTINATION bin)
endif()

# Generic settings
set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME};Empty Epsilon (${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})")
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_CONTACT "https://github.com/daid/")

set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/logo.png")
set(CPACK_PACKAGE_CHECKSUM SHA256)

# WIX (win installer)
# Setup the upgrade GUID to have one per version.
# https://tools.ietf.org/html/rfc4122#appendix-C
set(GUID_NAMESPACE_URL 6ba7b810-9dad-11d1-80b4-00c04fd430c8) # "Name string is URL" - in the appendix linked above.
string(UUID EMPTYEPSILON_GUID NAMESPACE ${GUID_NAMESPACE_URL} NAME "https://github.com/daid/EmptyEpsilon" TYPE SHA1)

string(UUID CPACK_WIX_UPGRADE_GUID NAMESPACE ${EMPTYEPSILON_GUID} NAME "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}" TYPE SHA1)
set(CPACK_WIX_UI_BANNER "${CMAKE_CURRENT_SOURCE_DIR}/resources/logo_full.png")
set(CPACK_WIX_UI_DIALOG "${CMAKE_CURRENT_SOURCE_DIR}/resources/logo_white.png")
# Add/Remove programs info.
set(CPACK_WIX_PROPERTY_ARPHELPLINK "https://daid.github.io/EmptyEpsilon/#tabs=6")
set(CPACK_WIX_PROPERTY_APPURLINFOABOUT "https://daid.github.io/EmptyEpsilon/#tabs=0")
set(CPACK_WIX_PROPERTY_ARPURLUPDATEINFO "https://daid.github.io/EmptyEpsilon/#tabs=5")
set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/logo.ico")

if(NOT DEFINED CPACK_GENERATOR)
  if(WIN32 OR STEAMSDK)
    set(CPACK_GENERATOR "ZIP")
  elseif(UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libfreetype6, libsdl2-2.0-0")
  endif()
endif()

# Allows injection of per-generator logic.
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPackProjectConfig.cmake.in" "${PROJECT_BINARY_DIR}/CPackProjectConfig.cmake" @ONLY)
set(CPACK_PROJECT_CONFIG_FILE "${PROJECT_BINARY_DIR}/CPackProjectConfig.cmake")

if(APPLE)
  if("DragNDrop" IN_LIST CPACK_GENERATOR)
    if(SDL2_LIBRARIES MATCHES "\\.framework$")
      # SDL2_LIBRARIES points to the framework itself.
      # For fixup_bundle to pick it up, we need to get its parent directory as the 'root'.
      # SDL2 also depends on hidapi.framework, which comes with the official DMG (https://libsdl.org/download-2.0.php)
      # Same idea - need the path to it for the dependency manager to pick it up.
      install(CODE "
        include(BundleUtilities)
        fixup_bundle(\"\${CMAKE_INSTALL_PREFIX}/EmptyEpsilon.app\" \"\" \"${SDL2_LIBRARIES}/..;${SDL2_LIBRARIES}/Versions/Current/Frameworks\")
      ")
    else()
      message(WARNING "macOS DMG packaging: ${SDL2_LIBRARIES} does not appear to be a framework. The bundle will not be fixed up properly.")
    endif()
  endif()
endif()

set(sp_runtime_root "/")

if ("WIX" IN_LIST CPACK_GENERATOR)
    if (EmptyEpsilon_VERSION_MAJOR GREATER 100)
	    # WIX does not like major version number > 256.
	    # So if we're above 100, assume it's a year-like format and strip out century/millenium.
	    math(EXPR wix_major "${EmptyEpsilon_VERSION_MAJOR} % 100")

        # WIX only care for the bundled PACKAGE_VERSION - fix only this one.
        set(CPACK_PACKAGE_VERSION "${wix_major}.${EmptyEpsilon_VERSION_MINOR}.${EmptyEpsilon_VERSION_PATCH}")
    endif()
    
    # WIX is... weird.
    # When packaging, it puts each 'component' into a subdirectory.
    # Things without a specific component fall under an 'Unspecified' catch-all one[1]
    # Now when using components, with install targets coming from different projects (via the CPACK_INSTALL_CMAKE_PROJECTS below)
    # it seems it's just... lost: components ends up in the root directory of the packaging tree instead of the component's.
    # So we shove everything that's coming from runtime straight under the 'runtime' tree, and voila, we pleased the CMake gods.
    #
    # [1]: https://cmake.org/cmake/help/v3.8/variable/CMAKE_INSTALL_DEFAULT_COMPONENT_NAME.html#variable:CMAKE_INSTALL_DEFAULT_COMPONENT_NAME
    set(sp_runtime_root "/runtime")
endif()

if(WIN32)
    # Since the runtime component is mandatory, no point in presenting it to the user.
    # This ensures we only display one entry as a 'bundle' in the MSI.
    set(CPACK_COMPONENT_UNSPECIFIED_DEPENDS runtime)
    set(CPACK_COMPONENT_RUNTIME_HIDDEN TRUE)
    set(CPACK_COMPONENT_RUNTIME_REQUIRED TRUE)
endif()

# Setup install targets:
# - For EE, we use everything that's been provided with install command.
# - For SP, we use only the things having the 'runtime' component (ie shared libs).
set(CPACK_INSTALL_CMAKE_PROJECTS
    "${PROJECT_BINARY_DIR};${PROJECT_NAME};ALL;/"
    "${PROJECT_BINARY_DIR}/SeriousProton;SeriousProton;runtime;${sp_runtime_root}"
)

include(CPack)

if(UNIX AND NOT APPLE AND NOT STEAMSDK)
  install(FILES EmptyEpsilon.desktop DESTINATION "share/applications")
  install(FILES logo.png DESTINATION "share/icons/hicolor/1024x1024/apps" RENAME "EmptyEpsilon.png")
endif()
