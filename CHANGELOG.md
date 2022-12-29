# Change Log

## [...]

### Added

- New scenarios
  - _Broken Glass_ #1795, #1796, #1798
- New translations
  - French scenario translations
    - _The Omicron Plague_ #1771, #1772, #1782, #1783, #1784, #1785, #1787
    - _Defender Hunter_ audio clips #1790
  - Translation hooks #1779, #1783

### Changed

- Mission time clock now uses `hh:mm:ss`-formatted time #1773
- Stats on Operations screen resized to match other screens #1774
- API changes
  - HTTP script access now uses the server-selected player ship as the default #1776
- Translation updates
  - French #1772, #1781, #1793

### Fixed

- ShipTemplate:copy() respects tube count limit for tubes, instead of beam count limit #1810
- URL for EmptyEpsilon website in scripting reference fixed #1791
- Relay can once again select alert level buttons #1786
- Main screen comms info no longer persists after it should be closed
- Banner text now cleared on scenario reset #1775
- Heading, velocity displays fixed on Single Pilot, Tactical screens #1774
- Build fixes
  - `update_locale` script target fixed
- Scenario fixes
  - _The Omicron Plague_ bugs fixed #1783, #1784, #1785, #1787, #1794
- Translation fixes
  - Translation hooks #1780

## [2022-10-28]

### Added

- Button on cinematic view automatically changes view to another ship every 30 seconds #1753
- API functions
  - `WarpJammer:getRange()` gets the jamming range #1759
  - `WarpJammer:get`/`setHull()` manages the jammer's hull strength #1759
- New scenarios
  - _The Omicron Plague_ #1738
- New translations
  - German scenario translations
    - _Battlefield_ #1746
    - _Training: Cruiser_ #1746
    - _Empty Space_ #1746
    - _What the Dickens_ #1745
    - _Defender Hunter_ #1742
    - _Surrounded_ #1742
    - _Waves_ #1733
  - Translation hooks #1732
- New settings
  - Hotkey for fullscreen toggle #1750
  - Analog joystick bindings for science scanning minigame (`SIENCE_SCAN_PARAM_SET_`...) #1770
  - Hotkeys for setting alert levels (`RELAY_ALERT_`...) #1765

### Changed

- Scripting documentation now lists class name with each member #1737, #1747
- Documentation for certain API functions improved #1743, #1759
- Sound attenuation at distance changed 1ef5a10
- Build changes
  - Code files restructured into more modular groups
- Scenario updates
  - _Basic Battle_ asteroid spawning updated
- Translation updates
  - French #1734
  - German #1733, #1742, #1745, #1746, #1758

### Fixed

- Missile tube indicators once again point from the tube's direction, instead of straight ahead #1751
- UI layer registration fixed c9b22b0
- Segfault crashes on radar views fixed #1760, #1763, #1766
- Glow effect interpolation fixed #1762
- Crash when sorting multiplayer object layers in radar view fixed
- UI layout infinite loop fixed
- Flickering/z-fighting between nebulae and other elements improved #1736
- Removed parens from resource filenames to fix `cmake`
- Relay text no longer flashes on update in upper corner #1735
- Text fields no longer scroll if they aren't multiline inputs
- Text cursor position now resets if text field contents are updated
- Avoid Operations screen crashes when ship is destroyed
- Scenario fixes
  - Missing `formatTime()` function added to `utils.lua` #1757

## [2022-03-16]

### Added

- Satellite ship templates, meshes, and textures #1696
- New reinforcement types added to default station comms script #1701
- Earth texture for planets #1698
- GUI is now themeable 79b7dde, #1681
- Steam SDK integration
  - Steam P2P connections possible
- Ships can now dock internally or externally to other ships, based on class 55e7992
- DMX events added for activating self-destruct sequence, countdown #1504
- Experimental multi-monitor support
- Configuration file path now logged
- Server port now configurable on server setup screen
- API functions
  - `getFactionInfo()` returns a FactionInfo reference e36c7ea 
  - Ship template functions `setExternalDockClasses()` and `setInternalDockClasses()` to configure how other classes of ship dock 55e7992
  - `sectorToXY()` converts a sector name to x/y coordinates #1651
  - `SpaceObject:sendCommsMessageNoLog()` hails a player ship to send a message, but doesn't log a failed delivery
- New translations
  - French scenario translations
    - Tutorials #1715
    - _Empty space_ #1666
    - _Battlefield_ #1665
    - _Surrounded_ #1663
  - Translation hooks #1617, #1623, #1624, #1629, #1637, #1638, #1639, #1640, 52f8905, #1656, #1660, #1664, #1683, #1691, #1700, #1705, #1731
- New settings
  - Hotkeys for top-down view (`TOPDOWN_`...) #1593
  - Hotkeys for cinematic view (`CINEMATIC_`...) #1593
  - `guitheme` and default GUI theme file `resources/gui/default.theme.txt` 79b7dde
  - `script_cycle_limit` to limit loop execution in scripts #1678
  - `multimonitor` to toggle experimental multi-monitor mode 7d5309b

### Changed

- Glitch, warp shaders converted
- Netboot script uses newer EmptyEpsilon and Debian versions
- Toggle buttons can now include icons
- Cinematic view readded
- HVLI damage buffed
- Scenarios now have their own locale files
- Engineering now shows unused coolant
- Options menu redesigned
- Database page layout refactored
- SpaceObject faction can now be changed during gameplay e36c7ea
- UI autolayout system replaced with SeriousProton 2 layout manager
- Warp, jump energy draw rebalanced 9c3198b
- Coolant distribution behavior changed d7efba3
- Scenario selection menu performance improved
- Linux app icon path changed to `hicolor` subdirectory #1658
- Text editing in multiline fields improved
- Server settings are now configurable while running 9e46814
- Crew position selection screen redesigned 43f2dfe, b0e1be7
- Sector naming patterns changed; use negative numbers "west" of 0, standardize capitalization "north" and "south" #514, #1628, #1651
- Settings files' path handling simplified
- Scenario settings localization handling improved
- API changes
  - `ShipTemplateBasedObject:setShieldsMax()` documentation improved #1729
  - `globalMessage()` now has a configurable timeout 274ae83
- Build updates
  - `CONFIG_DIR` removed
  - CI now builds Steam variant
  - CI now uses Visual Studio 17 2022
- Scenario updates
  - _Basic Battle_ victory alert converted from buttons to message #1730
  - _Fermi 500_ updated to version 2.1.0 #1725
  - _Basic_ renamed to _Basic Battle_ 263453f
  - _Beacon of Light_ updated #1699
  - _Surrounded_ now has a victory condition #1688
  - New station placement script `place_station_scenario_utility.lua` #1689
  - _Chaos of War_ updated to version 2 #1689
  - _Defender Hunter_ updated to version 10 #1661
  - Scenario sector name handling updated #1628, #1651
  - _Allies and Enemies_ updated to version 1 #1624
- Translation updates
  - French #1630, #1631, #1633, #1634, #1635, #1636, #1641, #1643, #1644, #1645, #1646, #1647, #1648, #1649, #1650, #1655, #1657, #1663, #1682, #1697, #1706, #1712, #1713, #1714, #1723
  - German #1627, #1707, #1711, #1726
  - Scenario translation contexts standardized #1615, #1617, #1620, #1621, #1622, #1623, #1625, #1642, #1721
- Changed settings
  - `touchscreen` applies only to Android builds
  - `last_server` now includes port number

### Fixed

- GM screen and custom function callbacks avoid undefined behavior
- Netboot build now set to `noninteractive` to skip keyboard layout checks
- Typos in tutorial, science database #1716
- Self-destruct dialog layout fixed
- Localized scenario audio clips are now played instead of English #1704
- Hotkeys no longer trigger UI controls that are explicitly made invisible
- Scripting reference document sorting, missing references, and errors fixed #1708, #1709, #1710, #1717
- Player ships flagged as indestructible can no longer be destroyed by reactor overloads #1702, #1703
- Station selection button no longer obscured in database view
- Hotkey binding page layout fixed
- Side 3D main screen now appears more consistently on widescreen displays 7df93ed
- Game crash on ship destruction while in Engineering fixed
- `SpaceObject:beamEffect()` example fixed
- Planet textures no longer flipped #1687
- Heading tooltip on Helm radar fixed #1684
- Custom functions now sorted on the server rather than the client
- Drawing selection boxes on GM screen fixed
- Random static effect on player ship destruction fixed #1670
- Nebulae inside zones no longer z-fight/flicker #1673
- Missing resource files logged on startup #1668
- Text on main screen cleared when resetting a scenario #1672
- Autoconnections to main screen fixed
- Target reticule in 3D viewport/main screen fixed #1675
- Power, coolant text alignment on Engineering screen fixed
- Text input now stops if a text field is removed while focused
- Avoid crashing when system damage is disabled
- You can no longer target yourself if you belong to a faction that's hostile to yourself
- Streaming ACN (sACN) now sends UDP data as expected 384df5f
- Packed resource handling in home directories fixed #1654
- Debug graphs no longer render offscreen #1653
- GM screen pause hotkey now toggles pause button state #1652
- MSVC builds fixed
- Display of localized hotkeys fixed
- Android config file check fixed
- Positional offset in ship's log text fixed
- Font size on waypoints fixed
- Successful hacking attempts now actually hack systems #1626
- API fixes
  - `globalMessage()` output now resized to fit text 274ae83
- Scenario fixes
  - _Birth of the Atlantis_ handles objects without warp jammers #1719
  - _Borderline Fever_, _Chaos of War_ ship template references fixed #1676
  - Enemies in _Waves_ no longer stay idle when spawned
  - _Birth of the Atlantis_ progress can now continue if player moves away from the artifact
  - _Basic_ message stating time remaining fixed

## [2021-11-27]

### Added

- Scenario settings can now be localized

### Changed

- Warp jammer behavior updated
- Player state reset and game simulation paused after selecting a new scenario
- Translation updates
  - French #1613, #1614, #1616

### Fixed

- Player ship in _Basic_ now gets warp drive even if its template doesn't include one

## [2021-11-12]

This release replaced core engine components, and it and future releases require GL 2.1 compatibility, a potentially breaking change for older devices.

### Added

- Scenario settings can now have default values [2dfb7c](https://github.com/daid/EmptyEpsilon/commit/2dfb7cc889a7ff55ceb00d76cc829400bc05aeb4)
- New master server registration screen with connection status #1567
- Multi-line text entry fields #1567
- New debug-build hotkey for FPS (<kbd>F10</kbd>) #1567
- Desktop launcher icon installed on Linux desktops #405, #1558
- Touch controls added for main screen #1553
- GL debug output through OpenGL extension [KHR_debug](https://www.khronos.org/opengl/wiki/Debug_Output) in debug builds #1549
- 3D model and packed resource support for Android #1535, #1540
- Back key on Android now works like <kbd>ESC</kbd> on other systems to back out of screens/exit #1567
- Beam weapons can now do different types of damange than just Energy
- API functions
  - `getScenarioSetting()` returns scenario-specific settings #1567
  - `SpaceShip:setBeamWeaponArcColor()` and `setBeamWeaponDamageType()`
- New scenarios
  - New _Basic_ scenario combines former _Basic_ and _Quick Basic_ scenarios with new settings [cb9e158](https://github.com/daid/EmptyEpsilon/commit/cb9e1586fcbc07da6558cca95db415fc88d0b928)
- New translations
  - French scenario translations
    - _Defender Hunter_ #1604, #1614
    - _Basic_ #1611
    - _Clash in Shangri-La_ #1594, #1610
    - _What the Dickens_ #1520, #1523
    - _Training: Cruiser_ #1519
    - _Escape_ #1515, #1523
    - _Deliver Ambassador Gremus_ #1514, #1523
    - _Ghost from the Past_ #1510
    - _Birth of the Atlantis_ #1508
  - Translation hooks #1486, #1499, #1506, #1511, #1512, #1522, #1567
  - German scenario translations
    - _Basic_ #1525, #1606
    - _Ghost of the Past_ #1525
    - _Birth of the Atlantis_ #1525, #1548
    - Tutorials #1487
- New settings
  - `server_scenario` setting to skip server creation and immediately start the scenario #1599
  - Fine-grained joystick control option for impulse throttle #1567
  - Main screen field-of-view angle configurable in the graphics tab of the Options screen and via `main_screen_camera_fov` #1555
  - Many new hotkeys #1567

### Changed

- Styling on scripting reference docs #1609
- Radars are now drawn in layers #1595
- Images on database screen are now treated as icons if a 3D model is associated with the entry #1587
- Explosion particles improved #1583
- Particle system performance improved #1580, #1584
- Vectors pass values by reference, improving memory performance #1579
- Zones implementation complete #529
- Credits updated
- Text is now selectable in input fields, and inputs handle text cursor movement better #1567
- Touchscreen functionality is now assumed by default, and the `touchscreen` setting now only forces mouse emulation when set to `0` and ignores any other value #1567
- Player ship jump/warp drive settings moved from global options to GM screen #1567
- Server creation menus redesigned #1567
- Model and View references improved #1541, #1547
- Lights now computed as directional in rendering #1539
- Android version now requests `INTERNET` and `ACCESS_NETWORK_STATE` permissions #1531
- Selector and indicator arrow images split into separate image resource files #1503
- Ship template script files reorganized
- UI image, texture, mesh, sound effect, and scenario audio clip files reorganized
- Custom functions are now indexed and can be reordered #1492
- UI selector text can now be resized #1489
- Hotkey UI entry fields widened #1485
- Rotating model view rendering improved #1476
- Build changes
  - LTO enforced on build targets #1608
  - Floating point number warnings addressed
  - Use `cmake`'s `tar` instead of `7z`, removing the dependency #1581
  - `json11` replaced with nlohmann/json #1572
  - Debian, macOS packaging updated #1571, #1576
  - Debug Android builds allow debugger to connect #1562
  - CI now builds with `ninja`
  - GL 2.1. / ES 2.0 compatibliity checks added #1546
  - Android APK build process updated #1531, #1540, #1552
  - CMake downloads SDL2 #1567
  - CMake-driven config header #1474
  - `ninja` build tool output colorized #1457
  - Source build version numbers fixed #1473
  - Use POSIX mingw
  - Default window title hardcoded #1474
  - Android builds use `OpenGL_GL_PREFERENCE=LEGACY` #1479
- SFML usage converted to SeriousProton/SDL/GLM
  - SFML references removed from CI #1571
  - Assert calls replaced with SDL #1567
  - Packaged resource handling now uses standard library for filesystem access #1560
  - Pointers now use SeriousProton ID types #1543
  - 3D meshes now optimized by [meshoptimizer](https://meshoptimizer.org/) #1542
  - Shaders migrated to new format #1533
  - CI updated to use SDL2 #1529
  - Input converted from SFML to SDL #1530, #1567
  - Rendering converted from SFML to SDL #1534, #1567
  - Rendering code uses SeriousProton abstractions instead of directly calling SFML
  - Unused render layers removed
  - HTTP server replaced with SeriousProton 2's
  - Shaders now require GL 2.0 #1483
  - Angle difference measurement moved out of SFML namespace
  - Fixed pipeline projection matrix removed #1481
  - SFML threads replaced with standard library
  - SFML `Clock` replaced with SeriousProton `SystemStopwatch`
  - Redundant `FindSFML.cmake` removed
  - GLM library moved to SeriousProton engine
  - SFML vectors replaced with GLM
  - SFML networking removed
    - Philips Hue devices now use SeriousProton HTTP requests #1475
    - SFML networking code replaced with SeriousProton code #1468
- API changes
  - `Planet` API and rendering adjusted #1590
  - `getScenarioVariation()` deprecated in favor of `getScenarioSetting()` #1567
- Scenario updates
  - More specific loop index variable name in _Basic_
  - All players receive timer warning in _Basic_
  - _Basic_ now uses scenario settings instead of deprecated variations
  - _Birth of the Atlantis_ updated with minor fixes #1567
  - _Shoreline_ updated to version 2 #1559
  - Scenario header setting fields no longer case sensitive #1567
  - Scenario `Type`/`Category` fields reorganized #1567
  - _Defender Hunter_ comms scripts #1522
  - Tutorial script files reorganized
  - Common tutorial script code moved into functions in `tutorialUtils.lua`
  - `comms_station_scenario_06_central_command.lua` script removed and inlined into _Edge of Space_
  - Short-range radar tutorial updated #1494
  - Dummy ships in tutorial can no longer be hailed #1494, #1495
  - _Borderline Fever_ updated to version 5.1.3 #1484
- Translation updates
  - French #1505, #1507, #1592, #1601, #1605, #1612, #1613
  - Czech #1500
  - German #1472, #1490, #1496

### Fixed

- Enemy ship in shields tutorial is now less aggressive #1607
- Improve handling of malformed objects #1603
- Scenario names and description translation display fixed
- Beam and turret logic fixed #1602
- Wormhole rendering on radar fixed #1588
- Username no longer ignored during autoconnect #1491, #1585
- Mines no longer spawn particles when running headless #1584
- Filesystem pathing build failures with GCC10 fixed #1582
- Unused audio recording functions for voice chat removed from Android builds, preventing crashes on certain devices #1574
- Combat maneuver hotkeys fixed
- Planets now use specular lighting #1566
- Beam arc rendering fixed #1567, #1600
- `get.lua` example in built-in HTTP server page fixed #1567
- Netboot crash fixed when `autoconnect=` setting value is null #1561
- Handling of meshes with more than 64k vertices fixed #1556
- Lighting positions fixed #1551
- Specular lighting fixed #1545
- UI element clicks on Android fixed #1538
- Tilde/backtick key (<kbd>`</kbd>) fixed for hotkey binding #1530
- Depth cutoff for 3D viewports fixed #1532
- `CpuShip:orderFlyFormation()` behavior with warp ships improved #1527, #1567
- Random noise overlay fixed
- Debug update time info graph (<kbd>F11</kbd>) fixed
- New UI elements are now properly initialized
- IP addresses fit better in server creation #1489
- GM tweak menu resized to prevent ship menu from overflowing #1488
- Empty model data no longer reported as unused
- macOS bundling during builds fixed #1469
- Server IP address entry field fixed #1468

## [2021-06-23]

### Added

- Language translation setting under interface options in Options screen #1423
- Ships can now have reverse speed and acceleration values #1353
- Hotkeys added to increase and decrease warp speed #1448
- Ship energy consumption, coolant, and heat rates can now be configured via scripting and GM tweaks #825, #1446
- Server browser shows a reason when a client disconnects #940, #1435
- Packaging added for macOS (DMG) and Windows (MSI) builds #1438
- Angle calculation functions added to `utils.lua` script #1408
- Preferences can now be saved on Android #1425
- API functions
  - `SpaceShip:getJumpDelay()` #1463
  - `SpaceShip:getDockingState()` #1463
  - `SpaceShip:get`/`setSystemHeatRate()` and `get`/`setSystemCoolantRate()` #1446
  - `PlayerSpaceship:get`/`setEnergyShieldUsePerSecond()`, `get`/`setEnergyWarpPerSecond()`, and `SpaceShip:get`/`setSystemPowerRate()` for energy consumption values #1446
  - `ScienceDatabase:setModelDataName()` sets a model for a science database entry #1152, #1434
  - `getGameLanguage()` returns selected translation language #1426
- New scenarios
  - _Training: Cruiser_ combat scenario #1424
- New translations
  - Translation hooks #1374, #1393, #1395, #1396, #1398, #1400, #1401, #1402, #1403, #1407, #1416
- New settings
  - `main_screen_flags` can toggle spacedust, headings, and callsigns on main screens #1430
  - `www_directory` sets relative path for the HTML server #1452

### Changed

- GM tweak no longer shows shields with IDs greater than the ship's shield count #1455
- Scanned beam-less or shield-less hostile ships no longer show  frequency graphs #1451
- Exuari ships now have custom radar icons #1424
- Shaders and 3D rendering refactored #1359
- Key/value GUI component code refactored #1443
- Reputation removed from station comms #1162, #1217, #1442
- Warp jammer ranges are now exported #1444
- Discord integration now supports Linux #1431
- 3D viewports/main screen now require GL 2.0 #1427, #1428
- Custom buttons and messages now appear automatically on related screens #1394
- Particle system compatibility improved #1392
- Scenario updates
  - _Basic_ scenario GM functions enhanced #1409
- Translation updates
  - Common buttons grouped for easier translation #1418
  - German translation updated #1467
  - French translation updated #1393, #1397, #1414, #1420

### Fixed

- `gcc` compilation warnings addressed
- Localization updating scripts fixed
- UI elements don't flicker or reposition when one is removed #1047, #1181
- "Defend a Waypoint" order fixed in ship comms script #1466
- Ship scan description now appears after selecting another ship with no scan description #1456, #1464
- Nebulas honor radar range #1462
- Object visibility on radar fixed #1461
- Radar is blacked out inside nebula #1461
- Short-range radar is always visible #1461
- CMake warnings on GNUInstallDirs addressed #1459
- 3D models no longer try to be rendered if 3D rendering is disabled #1458
- Hotkey remapping screen no longer removes joystick bindings #1454
- Clients no longer register duplicate missile explosions #1453
- Resizing the window while using a widescreen 3D side main screen no longer results in unstable 3D rendering #1450
- Radar no longer interferes with widescreen 3D side main screen #1447
- Comms no longer overlap reputation counter and clock on Relay #1442
- Rendering fixes on some older GPUs #1440
- Android builds fixed #1436
- Radars render correctly on Android #758, #1413
- Black hole render blending fixed #1429
- GM info can now be translated #1417, #1433
- SFML window activated before rendering 3D #1410
- Reversed textures on 3D models fixed #294, #1405, #1419

## [2021-03-31]

### Fixed

- Reverts hotkey config translation tags from #1382, preventing a crash

## [2021-03-30]

### Added

- macOS CI builds #1389
- API functions
  - `getActivePlayerShips()` returns a list of player ships #864, #1361
- New translations
  - Translation hooks #1279, #1377, #1383

### Changed

- Build now uses C++17 and updated CMake #1368, #1385
- Particle engine improvements #1367, #1370
- Translation updates
  - French translation updated #1371
  - Extended characters added to German translation #1357

### Fixed

- `clang` build fixed
- Building with older `gcc` versions fixed
- Hotkey configuration bug fixes #1384
- 3D viewports/main screen are no longer letterboxed on narrow windows #1373, #1376
- Particle spacedust no longer uses uninitialized data #1375
- Explosion GFX fixed #1364
- Text in radar views is now readable at all resolutions #1031, #1362
- Translation fixes
  - Fixes in Czech translation of science database #1378
  - Translation hook on GM object creation view fixed #1372

## [2021-03-16]

### Added

- New textures for planets and moons #1337
- Particle instancing for improved performance #1310
- Billboard shader, improving performance of quad rendering #1303
- GM info shows missile and mine ownership #1294
- Hotkey binding interface added to Options screen #1050, #1283
- GM controls for asteroids
- Proxy servers can be named #1040
- Cross-platform compiling added to CI #1241, #1248, #1345
- Native build support for MSVC #1186, #1266
- Generic stations report reputation value to comms #1217, #1270
- Reputation counter and timer to Operations screen #1017, #1221, #1285
- Missile size, owner, and target ID added to game state log
- New UI typeface BigShoulders
- API functions
  - `queryScienceDatabaseById()` to return a ScienceDatabase object with the given `multiplayer_id` value #1214
  - `getSize()` for `asteroid` and `visualAsteroid`
  - `SpaceShip:get`/`setSystemPowerFactor()` to set reactor output #1071, #1244
  - Crew positions added to scripting reference #1273
  - Documentation for `CpuShip` AI scripting functions #1300
  - Scriptable scan probes: `PlayerSpaceship:commandLaunchProbe()`, `onProbeLink`/`Unlink()`, `commandSet`/`ClearScienceLink()`, and `ScanProbe:get`/`setTarget()`, `get`/`setOwner()`, `onArrival()`, `get`/`setSpeed()` #1295, #1298, #1306, #1307
  - `Artifact:onCollision`/`PlayerCollision()` to script artifact pickups and interactions #1326
  - `Artifact:setRadarTraceIcon`/`Scale`/`Color()` to customize artifact radar traces #1309
  - Scriptable missiles: `get`/`setTarget()`, `get`/`setLifetime()`, `get`/`setMissileSize()`, `getOwner()` for `HomingMissile`, `HVLI`, `Nuke`, `EMPMissile` #1291, #1294
  - `Mine:getOwner()` #1294
- New scenarios
  - _Chaos of War_ team combat scenario #1293
- New translations
  - Translation hooks #1188, #1194, #1196, #1197, #1200, #1201, #1202, #1207, #1208, #1210, #1211, #1212, #1213, #1215, #1218, #1219, #1247
  - French translation of science database #1151
- New settings
  - `font_regular`, `font_bold` settings for customizing fonts
  - Default keybindings for Weapons, Helms, Engineering screens #1289

### Changed

- Convert UTF-8 text elements to ASCII #1357
- Full player names now shown in crew position GM tweak view #1350
- Missile sounds change pitch based on missile size #1347
- Radar range GM tweaks moved from Player tab to Ship #1312
- Ships use radar ranges for targeting and firing #1327, #1348
- All ships have settable radar ranges #1312
- Voice chat toggle keys can now be rebound #1288
- Hacking dialog closes when target is out of range #1290
- Reactor output can be configured via GM menu or scripting #1071, #1244
- UI can make radar transparent #1277
- Radar tig visibility is now responsive to radar range #1276
- Hacking selection uses translated strings #1257
- `script_reference` path changed in bundled builds #1251
- Comms script text edited #1238
- Faction info text edited
- Removed `get`/`setWeaponTubeSize()` functions in favor of `get`/`setTubeSize()` #1025, #1222
- `scriptstorage.json` path uses `$HOME` environment variable
- Supply freighters can have jump drives
- GM tweak menu jammer improved
- Relay and comms functions refactored
- Updates in the script reference documentation
- Graphics performance improvements
  - GFX of beam effects and explosions improved #1296
  - 3D reticule moved to shaders #1314
  - Starfield background converted to a cubemap #1313, #1341
  - Shader initialization now skipped if OpenGL is unavailable #1308
  - Quads replaced with triangles #1322, #1349
  - Fixed lighting removed #1340
  - `glm` required as a build dependency #1346
  - Spacedust converted to shader for performance #1329
  - Debug views moved to shader #1332
- Translation updates
  - Czech translation updated #1355, #1358
  - Italian translation updated #1272
  - German translation updated #1258, #1280, #1324
  - French translation expanded #1151, #1153, #1154, #1182, #1183, #1243, #1245, #1250, #1258, #1261, #1263, #1265, #1269
- Scenario updates
  - _Waves_ refactored 
  - _Basic_ scenario logs variant on error #1155, #1216
  - _Fermi 500_ updated #1302
  - _Capture the Flag_ updated #1301
  - Many scenarios edited for typos, clarity, code consistency #1231, #1230, #1232, #1233, #1234, #1236, #1237

### Fixed

- Cinematic view now honors ship selection #1356
- Builds on Fedora fixed #1352
- Show ship's own short-range radar range on Relay if player ship is hostile to its own faction #1311
- `SpaceStation:setCommsFunction()` no longer crashes if using a function imported via `require` #1170
- Black holes no longer spawn near stations at the start of _Basic_ #1292
- Music can stop playing or remain disabled on screen exit #883
- `getVelocity()` scripting documentation fixed #1281
- Player ship names on GM screen now update if renamed #1268
- Science database entries no longer duplicated on client reconnection #1240, #1254
- Windows build targets improved #1252
- Fix installation path for Discord integration library #1253
- Use 64-bit Discord integration on 64-bit builds
- Scripting documentation compiler now works with Python 3 #1246
- Friendly AI ships attempt to avoid friendly fire #589
- Engineering values no longer rounded to be off by 1 #949, #1223
- Game state logging now stops when launching a new scenario in the same session
- Game state logging no longer attempts to log missiles that don't exist #1227
- Positional sound attenuation effect increased #1226
- Sounds play on remote clients #1224, #1225
- Weapon tubes no longer desync on load/unload #1048
- Black holes confirm whether an object still exists before trying to move it #1180
- Discord library issue blocking Linux builds #1000 
- Ship templates now have and use a default AI
- Scenario and ship template typos #1156, #1157
- Pathing algorithm now accounts for ship size to better avoid mines and asteroids
- French translation of space station templates #1151
- _Escape_ scenario messages and buttons now appear for Engineering+ screen #1286
- Bugs in _Scurvy Scavenger_, _Borderline Fever_ scenarios #1284

## [2020-11-23]

### Added

- Updates in the script reference documentation
- More variations of the "Adder" ship line and new frigates
- Mission settings can be read from scripts (like `areBeamShieldFrequenciesUsed()`, etc.) #1038
- New AI "evasion" for unarmed transports which tries to avoid enemies #1092
- `scripts` directory README #1094
- Scenario scripts can be compiled with LDoc to generate documentation #923
- Scan probes, jump drive ranges added to GM tweak menu
- New translations
  - German translation #1086
  - Initial Italian translation
  - Czech UI translation
- API functions
  - `getSectorName()` that can be called without needing a SpaceObject #1095
  - `getEEVersion()` returns the EE release version
  - `Zone:getLabel()` #1097
  - `ScanProbe:getLifetime()` and `ScanProbe:setLifetime()`
  - `CpuShip:orderRetreat()` #1089
  - `ElectricExplosionEffect:setOnRadar()` and `ExplosionEffect:setOnRadar()`
- New scenario _Scurvy Scavenger_

### Changed

- Missiles and nukes explode at the end of their lifetime #689
- Nukes and EMPs try to avoid areas
- Control code is no longer case sensitive
- Ships without beams will try to restock their missiles when they run out
- All transport ships use the new AI "evasion" by default
- Alerts are now centered in their UI container #1105
- Comms scripts refactored, edited, and reformatted #992, #1117
- UI optimized for ships with only front shields
- UI improved for navigating database entries in Science
- Scenario selection UI scrolls to last selected scenario #1018
- Scenario updates
  - _Deliver Ambassador Gremus_ updated to version 4 #1107
  - _Defender Hunter_ updated #1109
  - _Delta Quadrant Patrol Duty_ updated #1111
  - PvP scenario with bug fixes, script reformatted #1116, #1119
  - _Borderline Fever_ updated to version 5 #1120
  - _Capture the Flag_ updated to version 1.7
  - _Basic_, _Quick Basic_ refactored

### Fixed

- Aim lock is now working with auto rotate
- Hull strength is rounded up before it is displayed to avoid ships with `0` health #1099
- Hacking difficulty and selected games are stored #1011
- `BlackHole`s and `WormHole`s no longer affect `Zones`, `Beams` and `ElectricExplosions`
- Scenarios with the same file name as a default scenario don't show up twice #1010 #1081
- Won't attempt to spawn repair crew into ships with no rooms #1100

## [2020-08-25]

### Added

- `SpaceShip:hasSystem()`
- `SpaceShip:getTubeLoadTime()` and `SpaceShip:setTubeLoadTime()

### Fixed

- fix a crash on restarting due to an invalid iterator in the database

## [2020-08-07]

### Added

- Script function `commsSwitchToGM()` that allows to switch to a GM chat in comms
- translations added to ship templates and station names
- french translation
- `ShipTemplate::getLocaleName()`
- Script function `getScenarioTime()` allows to retrieve the game time
- Science database can be filled and edited from within scenarios. Additional methods have been added to the Lua API
  - `destroy()` can be used to remove selective entries or the whole pre-filled database from within scenarios
  - `getScienceDatabases()` returns a table of all databases at the root level.
  - sub entries can be traversed with `getEntries()` and `getEntryByName()`
  - key value pairs can be inquired and manipulated through `setKeyValue()`, `getKeyValue()`, `getKeyValues()` and `removeKey`.
  - `queryScienceDatabase()` allows to easily query for deeply nested entries
- Science database entries allow to display an image `ScienceDatabase:setImage()`
  - The image files have to be available on all clients in order to be displayed.
- more descriptions in the script reference
- allow to set a callback function when a new player ship is created on the ship selection screen `onNewPlayerShip`
- `allowNewPlayerShips()` can be used in scenarios to disable ship creation from ship selection screen
- tube size can be changed by GM
- GM tweak menu has been updated and is now able to modify much more settings
- GM can create VisualAsteroid, Planet and Artifact
- GM can create Player ships
- GM can limit the maximal health of a system
- added script functions `SpaceShip:setTubeSize()` and `SpaceShip:getTubeSize()`
- added the option to set hotkeys to reset system power to 100% or other discrete values
- added `SpaceShip::getJumpDriveCharge()` and `SpaceShip::setJumpDriveCharge()`
- added `SpaceShip:getAcceleration()` and `SpaceShip:setAcceleration()`
- Scenario "Unwanted Visitors" added
- added `SpaceShip:getDockedWith()`
- added `SpaceShip:getSystemHackedLevel()` and `SpaceShip:setSystemHackedLevel()`
- script function `onGMClick()` is capable of capturing GM click locations
- new file `ee.lua` that has constants for the most enums
- ships can repair and restock missiles on docked ships (`setRepairDocked()`, `setRestocksMissilesDocked()`)


### Changed

- Science database entries are sorted alphabetically.
- Minimum MacOS compatibility version has been set to `10.10`
- scrollbars are hidden if all text fits on screen
- layout of the science database was changed
- `local` is used more in all lua scripts
- the last selected scenario is pre-selected when exiting a scenario
- assets from `HOME` directory are read before `RESOURCE_BASE_DIR`
- missiles can not be fired during warp
- radar rotation option is also used by operations and single pilot

### Fixed

- _Ready_ button can no longer be clicked without having a ship selected
- Translations with context are no longer ignored #879
- calculate energy drain of the warp drive by its actual speed
- it is no longer possible to warp instantly out of a backwards movement
- entered IP addresses in the server browse menu are stripped of whitepaces
- fixed misplacement of the red/yellow alert overlay on split screen #902
- the `util_random_transports.lua` now selects all possible transports
- planets generate valid lua code again when exporting
- GM messages are deleted on mission resets
- `WormHole::onTeleportation()` is called for all SpaceObjects, not just ships
- Wormhole effect is no longer visible after exiting the wormHole
- beam positions for `battleship_destroyer_5_upgraded` fixed


## [2020-04-09]

### Added

- Options menu settings to allow radar views on Helms, Weapons, and Science stations (and their derivative crew 3/4 stations) to rotate around the player ship, instead of the ship rotating within the radar view.
- Adjustable and customizable impulse engine sounds.
  - Options menu settings for enabling impulse engine sounds across all stations, main screen only, or disabled, as well as setting its volume separate from master sound and music.
  - `setImpulseSoundFile()` ship template function to set a custom engine sound.
  - Default impulse sound moved from `resources/engine.wav` to `resources/sfx/engine.wav`.
  - New engine sound for the MP52 Hornet.
- Power Management station keybindings, sharing Engineering's.
- `SpaceShip::setWarpSpeed()` scripting function to set a ship's speed per warp level.
- Optional control code for the Spectate station.
- Translation markers added to many more game features, including player stations and weapon names.
- Custom functions added to Ship Log screen.
- `autoconnect_address` option to specify a server to autoconnect to, instead of relying on server autodiscovery.
- Toggleable player ship capabilities in ship templates, scripting, and the GM tweak menu: scanning (`canScan()`), hacking (`canHack()`), docking (`canDock()`), combat maneuvering (`canCombatManeuver()`), self destruction (`canSelfDestruct()`), and probe launching (`canLaunchProbe()`)
- `set` and `getSelfDestructDamage` and `SelfDestructSize` scripting functions to modify player ship self-destruction explosion size and damage.
- Probe radar radius is now visible on the GM screen.
- Mission clock on Relay and GM screens counts up from 0 seconds at the start of each scenario. Ship's Log UI is now also synchronized to this clock for consistency.
- `SpaceObject::onDestroyed()` callback when an object is destroyed, even if not by damage.

### Changed

- Reducing coolant in a system distributes it automatically to other systems, even if they are all empty.
- Warp drive energy usage scales to system damage and power level.
- Options menu is paginated to accommodate additional options.
- Black holes do even more damage closer to their center; more objects sucked into a black hole should be destroyed by damage and trigger the appropriate callback.
- Borderline Fever scenario refactoring
  - Added expedite dock function to Relay, added show player ship details on player console, added enemy behavior change option, reorganized GM buttons, GM buttons to display player ship details, take advantage of resizable asteroids by randomly resizing them, Added cartography office to relay for stations when docked, added possibility to revive repair crew, added possibility to recover lost coolant, handle rare nil case for angle of attack, reduce average size of warp jammer range
- Delta Quadrant Patrol Duty scenario refactoring
  - Add status summary to relay screen, Localize variables, Take advantage of resizable asteroids through randomization, fix beam presence recognition code, Add goods randomization arrays, Add list of player ship names for Crucible and Maverick as well as set up code, fix check for warp drive presence on player ship, fix placement of station Research-19, Change station Maverick to Malthus, Switch to placing station data in comms_data structure, fix transport handling, Add cartography office, fix Kojak mission, remove old diagnostic code, simplify freighter cargo interaction, fix reference to global getLongRangeRadarRange (deprecated), add chance for repair crew to be revived
- Defender Hunter scenario refactoring
  - Move constant definitions to their own function, Fix player ship beam determination code, Add goods randomization tables, move station placement function list creation to its own function, localize variables, move station data to comms_data structure, take advantage of resizable asteroids through randomization, add possibility of repair crew revival, add possibility of coolant recovery
- Escape scenario refactoring
  - Update goods handling, switch to putting more data in comms_data structure for stations, add use case for another set of debris, make asteroids vary in size at random, add freighter communication options, add more junk yard dogs, add more harassing Exuari during repair journey, add Engineering messages when max repairable health reached

### Fixed

- Tutorial no longer crashes when started.
- Missile tube sizes and HVLI projectiles are properly replicated to clients.
- Warp/glitch shaders no longer affect paused games.
- Persistent scripting storage (ie. `ScriptStorage.get()`) is no longer wiped upon load in a new EE instance.
- Engineering station no longer sometimes crashes while loading.
- Fixed some situations that could cause crew screens to crash when selecting Main Screen controls on Linux builds.
- Ship's Log screen no longer overlaps some station selection controls.
- Destroyed player ships no longer persist and appear multiple times in the ship selection screen.
- Joystick event handling no longer results in crew stations persisting after a player exits them.
- When the window is resized, the rendered area no longer shifts out of the window's bounds when warp/jump/glitch effects occur.

## [2020-03-22]

### Added

- Localization functions.
- Mappable joystick controls.
- Push-to-talk voice chat using opus.
  - Server chat is mapped to the Backspace key.
  - Same-ship crew chat is mapped to the Tilde (~) key.
- `proxy` and `serverproxy` preferences to run an EmptyEpsilon instance as a
  proxy or reverse proxy server.
- `getScriptStorage()` scripting function to access persistent data storage,
  and `:get()` and `:set()` functions to retrieve and add or modify it.
- `setColors()` and `getColors()` GUI functions, and R/G/B color profiles, for
  GuiButtons.
- `SpaceShip:getDynamicRadarSignatureGravity()`, `...Electrical()`, and
  `...Biological()` scripting functions.
- Shield generator frequency selector to Engineering+.
- Strategic Map (Relay without comms), Comms Only (Relay without map),
  and Spectator (GM without editing) stations in the alternative/extras
  category.
- GMs can tweak coolant and short/long-range radar range on player ships.

### Changed

- Long-range radar range (and short-range radar range) are now per-ship
  settings, rather than server-wide. Long-range radar range option no
  longer appears on the scenario selection menu.
  - `get...`, `setLongRangeRadarRange()` and `setShortRangeRadarRange()`
    scripting functions added to ShipTemplate and PlayerSpaceship.
- Clients set a username on the main menu, which also appears in the ship
  selection screen.
- DB button for targeted ship information appears to the left of the info
  on the Science and Operations stations.
- Callsigns appear on the cinematic view.
- Android always uses landscape mode.
- Fixes to patrol duty scenario.
- `instance_name` now also appears in the window title.

### Fixed

- OpenGL crash issue with mesh views.
- Alignment of touchscreen calibration button text.

## [2020-02-18]

### Added

- `ScanProbe:onExpiration()`, `ScanProbe:onDestruction()`, and
  `PlayerSpaceship:onProbeLaunch()` callback scripting functions.
- Scan object (`s`) and cycle objects not yet fully scanned (`c`) hotkeys
  added to Science and Operations.
- `Artifact:setSpin()` scripting function.
- Scripting reference docs for SpaceObjects.
- Beam frequency and system target selectors added to the Tactical station.
- `pauseGame()` and `unpauseGame()` scripting functions.
- `startpaused` option for `headless` servers.
- A simple Discord bot, located in `/discordbot` within the git repository.

### Changed

- Moved shield calibration hotkey configs in the preferences file from
  Engineering to Weapons. **This is a breaking change** if these hotkeys
  are already set in the preferences file:
  - `SHIELD_CAL_INC`
  - `SHIELD_CAL_DEC`
  - `SHIELD_CAL_START`
- Radar signatures for AI and player ships change dynamically based on
  ship activity, such as impulse power and jump drive activation.

### Fixed

- `Asteroid:setSize()` now works as expected.
- Pathfinding objects that start a scenario on the same coordinates are no
  longer flung millions of units away when the game is unpaused.
- Hacking settings are now replicated to clients.
- Raw radar signature waveforms when objects are beyond long-range radar range.
- `headless` servers no longer attempt to use or require graphics.

## [2020-01-15]

### Added

- Crucible corvette-class popper ship.
- Maverick corvette-class gunner ship.
- Terran Stellar Navy (TSN), United Stellar Navy (USN), and Celestial Unified
  Fleet (CUF) factions.
- `SpaceShip:setScanState()` and `SpaceShip:setScanStateByFaction()` scripting
  functions.
- `Planet:getPlanetRadius()` and `Planet:getCollisionSize()` scripting
  functions.
- `Mine:onDestruction()` callback scripting function.
- Planet radius in the game state log and viewer, and to GM screen script
  exports.
- Standalone Ship's Log view, moved from the Single Pilot station to Extras.
- `registry_registration_url` and `registry_list_url` settings in options.ini,
  to point at a custom Internet master registry server. Only `http://` URLs are
  allowed. For an example master server, see the `masterserver` directory in
  `daid/SeriousProton`.

### Changed

- _Shoreline_ and _Borderline Fever_ scenarios refactored to fix errors and add
  enhancements.
- Slowed down Hue lighting updates and added transition channel.
- Removed an extraneous ZIP from the build.
- Ship and target passed to the comms script interface.

### Fixed

- Crashes when the server port is already in use.
- Missing radar trace images for ships.
- Typos in scenarios.
- Carrier ships (ships that are docking targets) attempting to dock with
  themselves, preventing them from being able to dock with stations or other
  docking targets.
- Crashes caused by excessive recursion in the AI path planner.
- Game completion condition for the Minesweeper hacking game.

## [2019-11-01]

### Fixed

- Downgrade drmingw from 0.9.2 to 0.8.2 in order to avoid DLL issues on Windows 7.

## [2019-10-28]

### Added

- Hacking minigame refactored with difficulty selector. #683
- Engineering can mitigate and repair hacking.
- `BeamEffect` scripting functions:
  - `BeamEffect:setSource()` and `setTarget()` for targeting.
  - `setTexture()` and `setRing()` for visualization.
  - `setBeamFireSound()` and `setBeamFireSoundPower()` for audio.
  - `setDuration()`
- `SpaceShip:getBeamFrequency()`, `PlayerSpaceship:getBeamSystemTarget()`, and `PlayerSpaceship:getBeamSystemTargetName()` scripting functions.
- `self_destruct_countdown` length in seconds is now configurable in options.ini.
- `ship_window_flags` setting in options.ini to configure space dust, headings, and callsigns on window views.
- _Allies and Enemies_ scenario.

### Changed

- Improve missiles:
  - Missiles can have a size.
  - Missile size affects speed, turn rate, and radar icon size.
  - Damage and particle effects can now scale.
  - Ships can have missile tube sizes.
- Last server connection is remembered after being disconnected. #624
- "All" tutorial is listed first. #698
- _Borderline Fever_ scenario updated to use new scripting features.
- Circles designating warp jammer areas are now red if controlled by an enemy or orange if not. #704

## [2019-09-10]

### Changed

- Custom ship function caption updates can now refresh.

### Fixed

- Build the Windows package in CI.

## [2019-09-09]

### Added

- Progress sliders as a GUI control.
- `setRestocksScanProbes()` and getter scripting functions for configuring ships and stations.
- `setMaxCoolant()` and getter scripting functions to modify the total coolant available to Engineering/Power Management.
- GM screen allows modifier keys:
  - `Shift` adds objects to the current selection
  - `Ctrl` only selects stations and ships
  - `Alt` only selects objects from the same faction as the faction selector
- GM screen message overlay.
- tinyci implementation.

### Changed

- Can press Enter to connect after entering a server's IP address. #627
- Passwords are no longer case sensitive. #657
- Password field focus point is now visible. #626
- F1 help overlay shows modifier keys.

### Fixed

- Prevent compilation failures in Hue lights counter. #648
- Sun appears correctly on clients in the _Empty Space_ scenario. #651
- Avoid crashes when a ship is destroyed on the same tick as firing a beam. #622
- Fix a distance calculation issue.
- Copied ship templates report correct impulse acceleration and combat maneuver stats.
- Fix GL blackout issue on main screen and ship windows. #649

### Removed

- Code::Blocks project file removed in favor of CMake.

## [2019-05-21]

### Added

- _Borderline Fever_ scenario.
- _Capture the Flag_ scenario.
- _Escape_ scenario.
- More features for Hue light controls.
- `warp_post_processor_disable` flag in options.ini to disable warp effects. #636

### Changed

- Remove headings and callsigns from ship window views.
- Clarify dangers and variation descriptions in the _What the Dickens_ scenario.
- Convert scenario audio to OGG format.
- Code::Blocks project file updated.
- Add Maverick ship type and minor fixes for the _Defender Hunter_ scenario.

### Fixed

- Avoid a crash when calling `isEnemy()` or `isFriendly()` on a destroyed object.
- Planets can no longer hide in nebulas.
- Rear shield info no longer shows front shield damage reduction.
- Typos in scenarios.

## [2019-01-19]

### Added

- _What the Dickens_ scenario and audio resources.
- `getFiringSolution()` script method for calculating missile trajectories.
- Additional weapon sounds.
- `onTakingDamage()` and `onDestruction()` scripting event listeners added to `shipTemplateBasedObject`s and warp jammers.
- `onTeleportation()` scripting event listener added to wormholes.

### Changed

- GM actions management refactored.
- Improve _Defender Hunter_ scenario behaviors when played on a headless server without a GM pause.
- `onPickUpCallback()` script function renamed to `onPickUp()` and extended to SupplyDrop objects.

### Fixed

- Button state issues.
- Systems actually degrade when energy drops to critical levels.
- Issues with the _Birth of Atlantis_ scenario, including a potentially broken trigger and larger warp jammer ranges. #584
- Serial port configuration on Linux.

## [2018-11-16]

### Added

- _Carriers and turrets_ scenario and ship resources.
- _Defender Hunter_ scenario and audio resources.
- _Patrol Duty_ scenario and audio resources.
- _Close the Gaps_ scenario and ship resources.
- `Wormhole:getTargetPosition()` scripting function.

### Changed

- Upgrade SFML to 2.5.
- Update CMakeLists.
- `Artifact` object pickups can emit a callback.

### Fixed

- Improved display of disabled system damage.
- Typos in tutorials and database.
- Ships in formation don't unintentionally dock with stations.
- _Beacon_ scenario now uses `mission_state`. #582
- GL state lifecycle bug.

## [2018-09-06]

### Added

- `Zone()` scripting function for colored, labeled zones. #529
- _Shoreline_ scenario.
- _Fermi 500_ scenario.
- Callsigns for GM comms.
- `variation` scenario setting for headless servers.

### Fixed

- Small bugfix on finding MINGW DLLs.
- DMX: Fix E1.31 DMP layer packet octet 118 value.
- Typos in scenarios.
- Custom button placement in station GUIs.
- Radar overlay on macOS no longer blacked out.

## [2018-02-15]

### Added

- _Deliver Ambassador Gremus_ scenario.
- Scripts can set CpuShip orders.

### Changed

- Clean up the GUI code.
- SpaceObject:takeDamage allows setting the origin, frequency and system_target.

### Fixed

- Different approach to prevent the radar from capturing clicks. #498

## [2018-01-05]

### Changed

- Allow spawning explosions from scripts.

### Fixed

- Hang on start of tutorial with no tutorial selected.
- Add DMX cues for system status. #506

## [2017-12-25]

### Changed

- Make lower sector naming more logical.
- Reduced the amount of debug symbols in release builds.

### Fixed

- Custom buttons for single pilot ships.
- Case of OpenAL32.dll filename to match what was generated by the openal-soft sources.

## [2017-12-22]

### Added

- Compiler optimization flags.
- Attempt to make Philips Hue hardware work.
- Script function to play sound files on the server.

### Changed

- Pacing for beam aiming practise.
- Select selectable objects instead of targetable.
- Blackhole text in regard to escaping with different types of engines.
- Moved hardware devices to a separate directory.

### Fixed

- Rendering of far away planets.  Now done in multiple passes.
- Ship template was updating the wrong template. Fixes #494
- Tutorial correctly states that hull is only repaired when docked. Fixes #495
- Typos
- Custom fuction being removed before getting called. Fixes #501
- Missile Volley AI never firing. Fixes #500

### Removed

- `GameMasterUI` class. Issue #491

## [2017-11-03]

### Added

- Game Master slides to control combat speed.
- Random object creation helper functions.
- Joystick controls for single pilot screen.
- Weapon hotkeys for tactical and single pilot screens.

### Changed

- Can set a description on each object based on scan state.
- Darken screen when your ship is destroyed.

### Fixed

- (Possibly) Crash on the relay station when your ship is destroyed.
- Main screen buttons properly reset state on target follow selection.
- Spelling on _Birth of the Atlantis_ scenario.
- `TOGGLE_AIM_LOCK` will only work if button state is properly set.

## [2017-05-06] 

### Added

- Number of hotkeys for the tactical, engineering+ and single pilot screens.
- Hotkeys to navigate between the screens
- Attempt to disable screen saving when netbooting
- "Can be destroyed" flag for ship objects
- 3D sprite for black hole
- script function to set the number and maximum of probes

### Changed

- Adjusted the tutorial

### Fixed

- Typo in the tutorial
- Communication dialogs not opening for second time on Game Master screens
- Options.ini diffusion

## [2017-02-23]

### Added

- Tutorial menu
- Default hotkeys
- F1 shows the available hotkeys

### Changed

- Re-factored the all tutorial into individual stations

### Fixed

- Joystick bug that allowed the combat power to cool down while moving backwards

## [2017-01-19]

### Added

- 5U circle around players on the Game Master screen
- Target drone for the quick basic scenario to practice firing missiles
- `setShieldFrequency` function
- `getEnergy`/`setEnergy` functions that take `max_energy_level` into consideration
- CMake error if `DRMINGW_ROOT` is not set

### Changed

- Improved callback handling to prevent closures from being deleted while in use
- Renamed shield system to shield generators
- Timing of rescue ship in _Beacon of Light_ scenario

### Fixed

- Operations screen not being able to select things
- Set `RESOURCE__BASE__DIR` to fix missing resource directory when compling on FreeBSD
- Null pointer exception in getSystemHealth

## [2016-09-02]

### Added

- Operations tutorial (disabled)
- Option to loop tutorials from the command line
- Reset button when the tutorial is looping
- variant of the basic scenario that waits for the game master to start it so crews can get used to the interface
- Fully scanned ships now show frequencies and subsystem status in the science screen sidebar pages
- Scanned targets subsystems are colored red when damaged
- Ship control codes, which prevent a player from selecting a ship without the correct code
- `setControlCode(string control_code)` to add a control code to a ship via script or template
- Player page for the game master tweaks panel, to set control codes, see energy levels and manned stations
- Show the effectiveness of the beam subsystem on the Engineering screen (effects the rotation speed)
- Place/delete waypoints from the Operations screen
- Sound volume can be set in the options
- Help overlay and keyboard hotkey display
- Basic build instructions
- Relay can hack ship subsystems
- Planets can orbit other objects
- Scrolling banner of information for the cinematic screen
- Show planets in the 3D world

### Changed

- Adjusted the nebula in the basic scenario
- Avoid spawing asteroids on the player start position
- Game master friendly spawned ships are already scanned when created
- Expanded utils.lua (more documentation, `setCirclePos` and `vectorFromAngle`)
- Avoid spawning black holes too close to stations in the basic scenario
- Updated fighters and advanced gunships to the new template
- Systems become degraded when low on power (< 10%)
- Increased the height of the frequency graphs for better contrast
- Radar signatures can be referenced in scripts
- Game masters can change object callsigns and descriptions
- Replaced the hotkey system with something better
- Revised the options menu
- Improved the cinematic screen

### Fixed

- Prevent bad use of faction friend/foe calls from crashing the game
- Game crashed if the game master presses a button that is removed durring event handling
- Calls for reinforcements were impeded
- Science screen from overlapping or running off the bottom edge of the screen
- Orders not showing on the game master screen
- Text entry fields #373

## [2016-06-24]

### Fixed

- Fix issues preventing JC-88 from jumping in the _Birth of Atlantis_ scenario
- Initialize beam and turret arc values to fix crashes when drawing beam arcs on Odin dreadnoughts

## [2016-06-23]

### Added

- New scenarios
    - Quick Basic scenario (for quick setup and with a time limit)
    - The _Birth of Atlantis_ scenario, with less combat and focused more on features
- New ships and ship options
    - Jump Carrier ship template, capable of quickly carrying docked ships across extremely long distances
    - Maximum jump drive distance configurable per ship (`setJumpDriveRange()`)
    - Beam turrets, an option to make beam weapons rotate within an arc (`setBeamWeaponTurret()`)
    - Stations repair the hull of any docked ship
    - Flag to toggle whether ships and stations share energy with docked ships (`setSharesEnergyWithDocked()`)
    - Option for player ships to have automatic coolant distribution (`setAutoCoolant()`)
- New sounds
    - Self-destruct sequence
    - Shields up/down
- New Game Master screen features
    - Player ships' radar range indicators
    - Button to copy Lua script lines for selected objects to the clipboard
    - Option for the Game Master to intercept and respond to all player hails
    - Player ship selection on the game master screen
- New Engineering(+) screen features
    - Show the effects of boosting subsystem power
    - Flashing overheating warning icon
- New Science/Operations screen features
    - Target's hull information
- New Tactical screen features
    - Combat manuever controls
- New Relay/comms features
    - Ship's log overlay, which replaces the log screen
    - Colors for ship's log entries
- New spectator views
    - Top-down 3D view UI to follow a player ship (press <kbd>H</kbd> to expose UI)
    - Cinematic view; fly-by camera that follows player ship, with optional target lock. Same keyboard controls as top-down 3D view
- New main screen controls
    - Overlays can be displayed on the main screen
    - Target lock view, selectable if a player has a weapons station and main screen controls
    - Comms windows on main screen, selectable if a player has a comms station
- Game log and log viewer features (`/logs/index.html`)
    - Show the probe radius
    - Zoom slider
    - More faction colors
    - File picker input
    - Log station factions to game state log
- New scripting features
    - Scripts can move player crew positions (`transferPlayersToShip()`, `transferPlayersAtPositionToShip()`) and check if a station is occupied (`hasPlayerAtPosition()`)
    - Scenario type identifiers
    - Scenario descriptions can span multiple lines
    - `utils.lua` function to create a grid of objects
- Search list for Linux serial devices
- On-screen keyboard for text communications on touchscreen devices

### Changed

- AI
    - AI ships refill missiles when docked at a station
    - AI takes advantage of non-standard jump drive ranges
- Crew station interfaces
    - Alert overlay size reduced
    - Edges of warp jammers are more obvious
- Weapons/Tactical station interfaces
    - Aim lock buttons moved
    - Weapon tube control width reduced
- Relay station interface
    - Distant sector designations improved
    - Database view margins standardized
    - Change Relay's zoom control to a slider
- Science/Operations station interface
    - Synchronize the Science/Operations screen's zoom slider behavior with the mouse wheel zoom
    - Adjust Science station layout to avoid overlaps
    - Adjust Science info sidebar's database lookup button size and position to avoid overlap
    - Move Operations screen communication buttons to avoid overlapping the radar
- Engineering(+) station interface
    - Only show combat recharge modifier on Engineering screen's Maneuverability subsystem if the ship has combat maneuvers available
    - Engineering subsystem bars are more visible
    - Moved shield buttons on Engineering+ screen to avoid overlap
- Ship selection screen interface
    - Show which crew stations are occupied by players
    - Show how many players occupy each ship
    - Changed Ship Window angle selection to a slider
    - Changed selectors with only two options into toggle buttons
    - Show server's long-range radar range in U instead of raw values
    - Reworded headings and buttons
- Scripting
    - Moved callsigns and `setCallSign()` to _spaceObject_, allowing scripts to assign callsigns to any object
- Game state logging (`/logs/`) and log viewer (`/logs/index.html`)
    - Draw non-ship objects as circles
    - Sector designations
    - Moved the scenario loading code out of the scenario selection screeen
    - Show ship and station factions
    - Reset coordinates when loading a log if they are not a number
    - Move game state logging from server creation to start of scenario
    - Scale objects with zoom
    - Cap mouse wheel changes to avoid breaking the zoom
- Ships and ship options
    - Player ship hulls strengthened
    - Repair speeds increased slightly
- Expand and restyle the HTTP API sandbox (`/www/index.html`)
- Auto connect selects on filters rather than index

### Fixed

- Crew station interfaces
    - Missile tube state changes are more accurately reflected on the Weapons screen
    - Sector name rendering at edge of radar improved
    - Communications "OK" button doesn't overlap notification text
- Expand slider ranges on Game Master screen's Tweak UI
- Game state logging (`/logs/`) and log viewer (`/logs/index.html`)
    - Operations screen's communication buttons from appearing in the database view
    - Autoplay on game state log viewer
    - Game state logger performance
- Resolve issues with the weapons phase of the tutorial
- When exiting a scenario while using auto-connect, return to the auto-connect screen instead of ship selection
- Setting `on_value` on hardware blink effects

### Removed

- Swear words from communication scripts
- Text from red/yellow alert overlays

## [2016-06-02]

### Added

- New web folder content (`/www/index.html`)
    - HTTP API examples and sandbox
- Game state logs (`/logs/`) and log viewer (`/logs/index.html`)
    - Basic log viewer using HTML and Javascript
- Top-down 3D spectator view controls
    - Top-down controls for zooming (<kbd>R</kbd> and <kbd>F</kbd>) and panning (<kbd>WASD</kbd>)
    - Lock camera to player ships with <kbd>L</kbd>
    - Select player ships with <kbd>J</kbd> and <kbd>K</kbd>
    - GUI controls; visibility toggled with <kbd>H</kbd>
- Game Master screen interface features
    - Button to copy Lua script lines for all objects to clipboard
    - Buttons to create an asteroid or supply
- Single Pilot interface features
    - Combat manuever controls
- Helms station interface features
    - Missile tube indicators for helm
- Science station interface features
    - Raw scanner overlay on probe view
    - Button to open the Database view for the targeted ship
- Weapons station interface features
    - Icon for HVLI ammo
- Music features
    - Music playback on clients
    - Option to toggle music playback; defaults to play music only on Main Screen clients, with options to always or never play music
- Faction communications for Ktlitans
- AI ships include missile counts in status reports
- Basic logging of model pack contents

### Changed

- Game Master screen
    - Ship Tweak UI elements standardized
    - Tweak UI's speed slider range expanded to 35
    - Missile storage capacity and amount converted to sliders
    - Warp and jump drive toggles converted to toggle buttons
- Engineering station interface
    - New Engineering ship room background
    - Shields reduce more damage when overpowered
- Ships and ship features
    - When a ship takes hull damage, damage only 1 random subsystem instead of 5
- Helms/Tactical/Single Pilot station interface
    - Combat maneuver control is a two-dimensional rectangle instead of two sliders, allowing boosting and strafing at the same time
- Weapons/Tactical station interface
    - Improved the weapons UI when the shield frequency feature is disabled
- Replaced `std::stoi` calls with `toInt()` for consistency
- Standardized Database screen margins and distance between elements
- Ship and station communication scripts edited

### Fixed

- Window title is "EmptyEpsilon" on all platforms
- Communications button usable on Single Pilot screen
- Game state logging (`/logs/`)
    - Log information on stations
    - Game state log entry converted to Boolean
    - Small fixes to the game state logger
- Correctly modify player ship in _Edge of Space_ scenario
- Fix system-to-shield connection on ships with more than 2 shields

## [2016-05-22]

### Added

- Station descriptions
- Name of missile tube on the firing button
- Show the "ship destroyed" dialog even if the game is paused
- Game state logging (`/logs/`)
    - Log the game state to JSON during gameplay for post-game analytics
- Ships and ship options
    - Flavia and Flavia Falcon light transport frigate, to replace the deprecated tug
    - Player variant of the Flavia (Flavia P.Falcon)
    - Starhammer II corvette ship template
    - Player variant of the Piranha frigate ship template
    - Defense platform ship template, to replace deprecated weapons platform
    - Ship templates to replace strikeship and advanaced striker
    - Beam weapon and engine emitter positions on some models
    - Extra set of 3d models for use as frigates
- Headless server options
- Allow tweaking weapon tube details and availability at load time 
- Allow game master to change a ship's callsign

### Changed

- Scenarios
    - Use new ship templates in scenarios
    - Use new power/coolant request functions in the tutorial
- Crew station interfaces
    - Reduce alert overlay
- Science Database content
    - Add faction descriptions to Science database
    - Moved descriptions in the database to the rightmost column
    - Add ship descriptions
- Weapons/Tactical station interface
    - Label directional facing of weapons tubes
- Relay station interface
    - Waypoints can be dragged to change their position
    - Limit number of waypoints to 9
- AI
    - Prevent AI from firing missiles on scan probes
    - Improve AI missile behavior
- Ships and ship options
    - Adjust model sizes
    - Adjust beam weapon ranges
    - Allow scripts to set the number of repair crews in a ship template
- Use `pngcrush` to reduce file sizes

### Fixed

- Parts of the tutorial failing to appear
- Docking hardware event
- Iterating over the `small_objects` map doesn't modify it
- Ready button's enabled state on ship selection screen
- HVLI fires in correct direction
- Nebula positioning

## [2016-05-07]

### Added

- Try to support uDMX hardware
- Stalker sniper-type cruiser ship template
- Direction to waypoints outside radar range on Helms screen
- Waypoint color settings in `colors.ini`
- Basic scenario Game Master improvements
    - Game Master functions to manually spawn enemy waves and random allies
    - Blank variant with no enemies and no victory condition
    - Game Master functions to manually award victory
- Comments to scenario code
- Freighter ship templates

### Changed

- Clicking outside of a target on the Weapons station unselects the current target
- Reverse default order of weapon tube rows on Weapons/Tactical screens
- Shield frequency configuration moved from Engineering station to Weapons
- Power Management screen shows both the actual and requested levels of power and coolant for subsystems
- Move the alert overlay behind controls
- Docking is now defined by which classes are allowed to dock with a ship
- Improved the feedback of the "Link to Science" button on Relay
- Edit tutorial text

### Removed

- Custom ship template in the PvP scenario

### Fixed

- Friendly ship broadcasts
- Adjust ship station selection button
- hacked ships communications pointing to old script in _Ghost from the Past_ scenario
- missile AI only fires the tubes with a targeting solution
- AI only tries to jump with the drive is charged
- main screen controls
- station selection overlap
- broadcast to friendlies

## [2016-04-30]

### Changed

- Use generic distance unit (`U`) instead of kilometers/km
- Waypoint rendering
- Improve use of forward declarations
- Use a different icon for weapons tubes that can launch only mines

### Removed

- gui2.h *catch all* header

### Fixed

- Science cannot select targets when probe view is active
- Prevent multiple simultaneous communications to the same object
- Fix a compile warning

## [2016-04-28]
### Added
- icon to show missle tube direction
- corvette class ships *disabled*
- player variant of the corvette class ship *disabled*
- frigate variations *disabled*
- abort the game on script errors in important files
- ship templates can be copied
- quick debug button to show all ship models in a single overview
- all colors of the new models to the model\_data
- allow combat manuvering data to be set on active ships
- added functions to remove game master function buttons
- allow the amount of repair crew to be set per ship template and at runtime
- functions to get the current radar range
- draw the engine/tube/beam positions in the rotating model view when debugging
- allow the beam weapon energy and heat to be set per beam
- missile tubes have a direction

### Changed
- increase system power usage
- power and coolant take time to change
- append callsign when broadcasting
- msgamedev model to point in the proper direction
- slight improvement to the database view when there are lots of items
- science database uses a tree structure
- how the probe link is implemented in science
- player cruiser and missile cruiser use the directional tubes
- mines are fired in the direction of the tube
- missile path projections are only shown when loaded
- station selection from row of buttons to a drop down
- transparent wormhole images
- higher resolution blackhole image

### Removed
- custom ship templates from the _Ghost from the Past_ scenario
- obsolete functions

### Fixed
- crash when models are ot found
- slight layout
- database scroll bar overlapping with database entry
- label in game master screen for laser damage
- asking a friendlies status made it defend the player
- do not drain energy from docked ship when energy is full
- player spaceships and stations from being incorrectly reported as not used models
- margin calculations
- game master script buttons overlayed with ship orders

## [2016-04-12]
### Added
- allow the game master to close communications
- allow safe destory of GuiElements
- allow clipboard paste in text fields
- function to shutdown the game
- function to get what the game master has selected.
- examples of how to use the addGMFunction
- option to set margins on controls
- function to change the scenario to a different one.
- log to a file in windows
- allow the user to specify the serial port for DMX with or without /dev/ on linux
- server can register with the online master server
- browsing for LAN and internet servers
- server password
- 4 new ship models
- scan probe model
- logging to show which model data deinitions are not used by ship templates
- damage/power indicator for beam info
- engineering column icons
- show current frequency on the beam and shield curves in engineering

### Changed
- improve the dynamic layout of the ship selection screen for wide screens
- improve the dynamic layout of the serer start screen using the new column auto layout
- changed the default release log level to info
- use a different icon for the warp and jump drives
- server screen uses less magic numbers
- return to the scenario selection instead of closing the server
- improve science radar positions on wide screens
- improve the layout of engineering controls
- system icons updated

### Fixed
- unfocusElement which only worked for the top level element of the tree
- possibly fixes keyboard related crashes
- changes to server name were never applied
- scroll bar look
- touchscreen calibration
- main screen first person view rotating like an idiot

## [2016-04-07]
### Added
- indication that chat has changed on game master chat dialogs that are minimized
- image for the resize corner
- include ship tweaks when exporting from the game master screen with F5
- icons for _Tactical_ and _Single Pilot_
- option to tweak ships from the game master interface
- indicators ticks for power and coolant
- function to broadcast faction messages
- AI ships inform when taking new orders
- state to let the communication officer to know when the other side closed communication
- option to abort docking
- scan state for ships
- icons for each support OS
- joystick controls for 3/4 player tactical screens
- allow for direct and hex value entry
- per station settings for which weapons they supply

### Changed
- cursor blinks in text emptry field
- constrain resizable dialogs to the window
- game master can have multiple sessions
- updated icons for stations
- updated logo on the main menu
- more realistic asteroid texture
- new cursor design
- resized button icons to fit better
- round beam range on 100m intervals
- game master screen now has multiple pages
- broadcast function has three thresholds: allies, neutral, all
- new shield, hull and self destruct icons
- increased the sharpness of the skybox
- updated the star field image
- images for active/disabled/hovered buttons
- images for regular/focused text inputs
- updated colors
- alpha transparency for UI elements

### Fixed
- text centering
- shield icon using speed icon
- inverted pause button
- create button visible through the cancel button on game master screen
- clicking outside the radar circle but inside its reactangle caused callbacks

[Unreleased]: https://github.com/daid/EmptyEpsilon/compare/EE-2018.02.15...HEAD
[2018-02-15]: https://github.com/daid/EmptyEpsilon/compare/EE-2018.01.05...EE-2018.02.15
[2018-01-05]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.12.25...EE-2018.01.05
[2017-12-25]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.12.22...EE-2017.12.25
[2017-12-22]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.11.03...EE-2017.12.22
[2017-11-03]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.05.06...EE-2017.11.03
[2017-05-06]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.02.23...EE-2017.05.06
[2017-02-23]: https://github.com/daid/EmptyEpsilon/compare/EE-2017.01.19...EE-2017.02.23
[2017-01-19]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.09.02...EE-2017.01.19
[2016-09-02]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.06.24...EE-2016.09.02
[2016-06-24]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.06.23...EE-2016.06.24
[2016-06-23]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.06.02...EE-2016.06.23
[2016-06-02]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.05.22...EE-2016.06.02
[2016-05-22]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.05.07...EE-2016.05.22
[2016-05-07]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.30...EE-2016.05.07
[2016-04-30]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.28...EE-2016.04.30
[2016-04-28]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.12...EE-2016.04.28
[2016-04-12]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.07...EE-2016.04.12
[2016-04-07]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.02.29...EE-2016.04.07
