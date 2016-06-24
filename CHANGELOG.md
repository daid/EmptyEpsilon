# Change Log

## [2016-06-23]
### Added
- _Birth of Atlantis_ scenario, less combat and more feature focused
- configurable turrets (arc, direction and rotation rate)
- beam turrets
- self-destruction sound
- show the player radar range on the game master screen
- game master button to copy the selected object to the clipboard
- function to create a grid of objects
- flag to allow selective repairs on docked ships
- flag to allow sharing energy with docked ships
- a jump carrier
- scenario type identifiers
- quick basic scenario (for quick setup and with a time limit)
- colors for log entries
- on-screen keyboard for text communications
- option for the game master to intercept all communication requests
- named background overlays
- target lock view for main screen
- show the probe radius
- overlays can be displayed on the main screen
- communications display for the main screen
- zoom slider for the log viewer
- more faction colors in the log viewer
- file picker input
- ships log control which replaces the log screen
- max jump drive distance per ship configuration
- log station factions to game state log
- option for player ships to have automatic collant distribution
- scripts can move player crew positions and check if a station is taken
- show the effect of boosting power into subsystems
- flashing overheating warning icon in engineering
- hull information on the science screen
- search list for linux serial devices
- player ship selection on the game master screen
- cinematic view
- target-of-target toggle and controls
- combat manuever controls for the tactical screen

### Changed
- tweaked the game master sliders
- shield sounds
- AI ships recharge missiles when docked at a station
- edge of warp jammers are more obvious
- how sectors are named for far away sectors
- work around possible issues in the tutorial
- AI jump drive behavior for non-standard jump drive distances
- scenario descriptions can be multi line
- moved the scenario loading code out of the scenario selection screeen
- aim lock button placement
- all ships repair hull when docked
- hide the radar graident in the database view
- reduce width of missile tube controls
- smaller alert overlay without the bars on the top and bottom
- tweak non-ship object rendering in log viewer
- moved _setCallSign_ to _spaceObject_
- draw non-ship objects as circles
- moved callsigns to _spaceObject_
- sector designations on the log viewer grid
- use square/circle drawing functions in the log viewer
- separated the on-screen layers from the overlays
- allow communications overlay to be manually cleared
- show which stations are occupied and by how many
- show the ship faction
- changed the ship angle selection to a slider
- moved square and circle drawing into functions
- reset coordinates when loading a log if they are not a number
- database view margins
- change zoom control to a slider on the relay screen
- auto connect selects on filters rather than index
- adjusted the science screen to avoid overlay
- ship database lookup button position
- only show combat recharge if the ship has combat maneuvers available
- moved shield buttons from system info on Eng+
- move game state logging from server creation to start of scenario
- expand and restyle the API sandbox
- move game state logging to _gameGlobalInfo_
- boost player hulls
- improve engineering bar colors
- slightly increased repair speeds
- two option selectors to toggle button on the server creation screen
- show radar range in U instead of raw values
- reworded some headings and descriptions on the server creation screen
- scale objects with zoom
- cap mouse wheel changes to avoid breaking the zoom
- move ops communication buttons to avoid overlapping the radar
- synchronize the science zoom slider behavior with the mouse wheel zoom

### Fixed
- performance issue with the game state logger
- sector name rendering at edge of radar
- communications buttons
- missile tube state change
- return to the auto connect screen instead of ship selection when auto connect is used
- autoplay
- hardware blick effect, could not set on\_value
- prevent ops communication buttons from appearing in the database view

### Removed
- debug messages
- swear words from communication scripts
- alert text

## [2016-06-02]
### Added
- example of HTTP API
- basic log viewer using HTML and Javascript
- combat manuevers controls for single pilot screen
- SIL OFL for _Bebas Neue_
- toggle GUI visibility with <kbd>H</kbd> and camera locking with <kbd>L</kbd>
- top-down controls for zooming and panning
- selector for picking a players ship to lock onto
- button to copy a scenario script to clipboard
- buttons to create an asteroid or supply drop for the game master
- missile tube indicators for helm
- raw scanner overlay for science probe view
- button to the science station to open the database to the selected ship
- icon for the HVLI
- window title to cmake file
- option to toggle music
- faction communications for _Ktlitans_
- status requests respond with missile counts
- basic pack logging

### Changed
- engineering ship room image #271
- tweaks to the panel UI (see [4c96062155cd33433ff5b40a8c3fbb12b1815af1](https://github.com/daid/EmptyEpsilon/commit/4c96062155cd33433ff5b40a8c3fbb12b1815af1))
- damage is done to a single sytem instead of 5 random systems
- combat maneuvering is now two dimensional allowing boosting and strafing at the same time
- improved the weapons UI when the shield frequency feature is disabled
- shield damage factor when there is more power in the shield system
- replaced std::stoi with toInt to be more consistent
- database screen div distance
- moved music to the clients
- ship and station communication scripts

### Fixed
- communications button on single pilot screen
- logging on stations
- game state log entry being converted to bool
- _Edge of Space_ scenario was modifying the player ship incorrectly
- small fixes to the game state logger
- Fix system <-> shield link when there are more than 2 shields

## [2016-05-22]
### Added
- station descriptions
- name of missile tube on the firing button
- show the ship destroyed dialog even if the game is paused
- log the game state every X sections for post game analytics
- engine emittors for more models
- player controled _Flavia_
- _StarHammer_ corvette
- beam weapon and engine positions on some models
- player variant of the Piranha
- headless options
- defense platform to replace weapons platform
- allow tweaking missile tube details and availability at load time 
- allow game master to change callsigns
- strike craft to replace strikeship and advanaced striker
- light transport frigate to replace the Tug
- extra set of 3d models for use as frigates

### Changed
- use the new ship templates in the scenarios
- alert overlay is more minimal
- faction descriptions
- moved descriptions in the database to the rightmost column
- ship descriptions
- direction facing labeling
- prevent AI from firing missiles on scan probes
- improve AI missile behavior
- new power/collant request functions in the tutorial
- model sizes
- beam weapon ranges
- allow scripts to set the amount of crew memebers in a ship template
- relay can drag waypoints to change their position.
- limit waypoints to 9
- use pngcrush to reduce file sizes

### Fixed
- repair things not showing up in the tutorial
- hardware event Docking
- do not modify the small\_objects map while iterating over it
- ready button not always enabled on ship selection
- HLVI firing in opposite direction
- nebula positioning

## [2016-05-07]
### Added
- try to support uDMX hardware
- sniper type cruiser
- show the direction to waypoints outside radar range
- waypoint color is configurable
- game master can manually spawn enemy waves and random allies in the basic scenario
- blank scenario with no enemies and no victory condition
- game master fucntion to manually award victory
- commented the scenario code
- freighters
- clicking on no target will unselect the current target in the weapons console

### Changed
- moved the shield frequency configuration to weapons
- power management shows the actual and requested levels
- draw the alert overlay behind controls
- docking is now defined by which classes are allowed to dock with a ship
- improved the link-to-science feedback on relay
- tutorial text
- reverse missile weapon rows

### Removed
- custom template in the PvP scenario

### Fixed
- broadcast & station selection button
- hacked ships communications pointing to old script in _Ghost from the Past_ scenario
- missile AI only fires the tubes with a targeting solution
- AI only tries to jump with the drive is charged
- main screen controls
- station selection overlap
- broadcast to friendlies

## [2016-04-30]
### Changed
- km with "distance unit"
- waypoint renderingo
- better use of forward declarations
- different icon for missile tube that can only launch mines

### Removed
- gui2.h *catch all* header

### Fixed
- science cannot select targets when probe view is active
- multiple communications to the same object at the same time
- compile warning

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

[2016-06-23]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.06.02...EE-2016.06.23
[2016-06-02]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.05.22...EE-2016.06.02
[2016-05-22]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.05.07...EE-2016.05.22
[2016-05-07]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.30...EE-2016.05.07
[2016-04-30]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.28...EE-2016.04.30
[2016-04-28]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.12...EE-2016.04.28
[2016-04-12]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.04.07...EE-2016.04.12
[2016-04-07]: https://github.com/daid/EmptyEpsilon/compare/EE-2016.02.29...EE-2016.04.07
