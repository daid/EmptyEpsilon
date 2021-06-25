# Set minimum target macOS version: https://cmake.org/cmake/help/v3.8/variable/CMAKE_OSX_DEPLOYMENT_TARGET.html#variable:CMAKE_OSX_DEPLOYMENT_TARGET
# SFML targets 10.7, however EE targets C++17 features only available in 10.15+ (Catalina, June 2019).
# Must be first!
if(NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
  set(ENV{MACOSX_DEPLOYMENT_TARGET} "10.15")
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
endif()

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

if (WITH_DISCORD)
  list(APPEND SOURCES src/discord.cpp)
endif()

if (WIN32)
  list(APPEND SOURCES EmptyEpsilon.rc)
endif()


if(ANDROID)
    add_library(${PROJECT_NAME} SHARED ${SOURCES})
else()
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SOURCES})
endif()

target_compile_definitions(seriousproton_deps
    INTERFACE
        WINDOW_TITLE="${PROJECT_NAME}"
        VERSION_NUMBER=${PROJECT_VERSION_MAJOR}${PROJECT_VERSION_MINOR}${PROJECT_VERSION_PATCH}

        # Set RESOURCE_BASE_DIR on Unix so the built binary is able to find resources
        $<$<BOOL:${UNIX}>:RESOURCE_BASE_DIR="${CMAKE_INSTALL_FULL_DATADIR}/emptyepsilon/">
        $<$<BOOL:${CONFIG_DIR}>:CONFIG_DIR="${CONFIG_DIR}">
        $<$<NOT:$<BOOL:${CONFIG_DIR}>>:CONFIG_DIR="${CMAKE_INSTALL_FULL_DATADIR}/emptyepsilon/">
)

target_compile_definitions(${PROJECT_NAME} PUBLIC WITH_DISCORD=$<BOOL:${WITH_DISCORD}>)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)

add_library(opengl INTERFACE)
target_link_libraries(opengl
    INTERFACE
        "$<IF:$<BOOL:${ANDROID}>,GLESv1_CM;EGL,OpenGL::GL>"
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        seriousproton opengl
        "$<$<BOOL:${ANDROID}>:log;android>"
        "$<$<BOOL:${WIN32}>:iphlpapi>"
        "$<$<BOOL:${WITH_DISCORD}>:discord_h>"
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

    if(MSVC)
      # Not all configuration emit a pdb (ie Release), make this optional.
      install(FILES "$<TARGET_PDB_FILE:${PROJECT_NAME}>" DESTINATION . OPTIONAL)
    endif()
elseif(APPLE)
  install(FILES logo.icns DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources" RENAME "${PROJECT_NAME}.icns")
  install(DIRECTORY ${EE_RESOURCES} DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources")
elseif(ANDROID)
  android_apk(EmptyEpsilon)
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
  if(WIN32)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION . OPTIONAL)
  elseif(APPLE)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "$<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>/Resources" OPTIONAL)
  elseif(NOT ANDROID)
    # DOCDIR already has PROJECT_NAME (EmptyEpsilon) appended (from CMake docs)
    install(FILES "${SCRIPT_REFERENCE_HTML}" DESTINATION "${CMAKE_INSTALL_DOCDIR}" OPTIONAL)
  endif()
endif()

add_custom_target(update_locale
    COMMAND xgettext --keyword=tr:1c,2 --keyword=tr:1 --keyword=trMark:1c,2 --keyword=trMark:1 --omit-header -d resources/locale/main.en ${SOURCES}
    COMMAND xgettext --keyword=_:1c,2 --keyword=_:1 --omit-header -j -d resources/locale/main.en scripts/shipTemplates_*.lua scripts/comms_ship.lua scripts/comms_station.lua scripts/comms_supply_drop.lua scripts/factionInfo.lua scripts/science_db.lua
    COMMAND xgettext --keyword=_:1c,2 --keyword=_:1 --omit-header -d resources/locale/tutorial.en scripts/tutorial_*.lua
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
  if(WIN32)
    set(CPACK_GENERATOR "ZIP")
  elseif(UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libsfml-dev")
  endif()
endif()

# Allows injection of per-generator logic.
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CPackProjectConfig.cmake.in" "${PROJECT_BINARY_DIR}/CPackProjectConfig.cmake" @ONLY)
set(CPACK_PROJECT_CONFIG_FILE "${PROJECT_BINARY_DIR}/CPackProjectConfig.cmake")

if(APPLE)
  if("DragNDrop" IN_LIST CPACK_GENERATOR)
    if(DEFINED SFML_ROOT)
      if(SFML_ROOT MATCHES "Frameworks$")
        # Copy SFML and its extlibs to binary dir.
	      # SFML_ROOT *should* be the Frameworks folder!
	      execute_process(
		      COMMAND ${CMAKE_COMMAND} -E copy_directory "${SFML_ROOT}/" "${CMAKE_BINARY_DIR}/Frameworks/"
		      COMMAND ${CMAKE_COMMAND} -E copy_directory "${SFML_ROOT}/../extlibs/" "${CMAKE_BINARY_DIR}/Frameworks/")
	      install(CODE "
  		    include(BundleUtilities)
  		    fixup_bundle(\"\${CMAKE_INSTALL_PREFIX}/EmptyEpsilon.app\" \"\" \"${CMAKE_BINARY_DIR};${CMAKE_BINARY_DIR}/Frameworks\")
	      ")
      else()
        message(WARNING "macOS DMG packaging: SFML_ROOT *must* point to SFML's Frameworks folder (no trailing slashes). The bundle will not be fixed up properly.")
      endif()
    else()
      # This is usually the case when using sfml from homebrew, which sadly not portable enough for DMG packages.
      message(WARNING "macOS DMG package requested - please set SFML_ROOT, otherwise the bundle will not be fixed up properly.")
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
