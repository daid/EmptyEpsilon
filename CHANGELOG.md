# Change Log

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
