# The directory `scripts`

The Lua files are used in different ways.

## Hard-coded usage

These files should be equal on the server and all clients.

- `factionInfo.lua`
- `model_data.lua`
- `science_db.lua`
- `shipTemplates_*.lua`

The following files only need to exist on the server.

## Useful to `require` in scenarios

- `ee.lua` with EmptyEpsilon constants
- `luax.lua` with additional Lua functions
- `utils.lua`
  - `perlin_noise.lua`

## Scenarios and tutorials

- `scenario_*.lua` (Some scenarios are not yet renamed.)
  - 00 ... basic scenarios
  - 05 ... missions
  - 10 example showing creation of space objects
  - 47 ... Xansta's scenarios
  - 80 ... player vs. player
  - 90 ... not really scenarios
- `tutorial_*.lua`

## Scripts for scenarios

- `supply_drop.lua`
  - uses `comms_supply_drop.lua`
- `util_random_transports.lua`

## Communication

The default communication scripts for each created ship or station.

- `comms_ship.lua` (hard-coded default for ships)
- `comms_station.lua` (hard-coded default for stations)
  - uses `supply_drop.lua`
- `comms_supply_drop.lua` (used by `supply_drop.lua`)
- `comms_station_scenario_06_central_command.lua` (used by `scenario_06_edgeofspace.lua`)

They can be replaced by `obj:setCommsScript(filename)` or `obj:setCommsFunction(callback)`.
