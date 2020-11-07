# The directory `scripts`

The Lua files are used in different ways.

## Hard-coded usage

These files should be equal on the server an all clients.

- `factionInfo.lua`
- `model_data.lua`
- `science_db.lua`
- `shipTemplates_*.lua`

The following files only need to exist on the server.

## Useful to `require` in scenarios

- `ee.lua`
- `utils.lua`
  - `perlin_noise.lua`

## Scenarios and tutorials

- `scenario_*.lua`
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

They can be replaced by `obj:setCommsScript(filename)` or `obj:setCommsFunction(callback)`.
