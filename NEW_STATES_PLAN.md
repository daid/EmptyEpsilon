# Hardware Game-State Lighting Variables

## Summary

Add two numeric variables for `hardware.ini` mappings:

- `RunningScenario`: `1.0` while a scenario is loaded/running, `0.0` otherwise.
- `ShuttingDown`: `1.0` only during final hardware shutdown flush, `0.0` during normal runtime.

These variables should work on both the host/server and connected client stations so station-attached lighting can respond consistently.

## Implementation

- Add a replicated `GameGlobalInfo::scenario_running` boolean, initialized false.
- Set `scenario_running = true` after `startScenario()` successfully loads the scenario script.
- Set `scenario_running = false` from `reset()` and destroy paths.
- Expose `RunningScenario` in `HardwareController::getVariableValue()` from replicated `gameGlobalInfo->scenario_running`.
- Expose `ShuttingDown` in `HardwareController::getVariableValue()` from a local shutdown flag.
- Add `HardwareController::shutdown()` to set the shutdown flag, flush `update(0.0f)` once, then wait `100 ms`.
- Call the hardware shutdown flush after `engine->runMainLoop()` returns and before window/engine teardown.

## Hardware.ini Behavior

Existing syntax remains unchanged.

Example usage:

```ini
[state]
target = bridge_light
condition = RunningScenario
value = 1.0

[state]
target = menu_light
condition = RunningScenario == 0
value = 1.0

[state]
target = exit_light
condition = ShuttingDown
value = 1.0
```

`RunningScenario` uses the existing default `> 0` condition behavior when no operator is provided. `ShuttingDown` is intended for final/default exit lighting only, not for normal menu states.

## Test Plan

- Build the project to verify the replicated field and hardware controller changes compile.
- Use `VirtualOutputDevice` with a small `hardware.ini` to verify:
  - `RunningScenario` is `0` at the main menu.
  - `RunningScenario` becomes `1` after loading a scenario.
  - `RunningScenario` returns to `0` after resetting/disconnecting back to non-scenario state.
  - `ShuttingDown` activates the configured output during final application exit.
- For multiplayer behavior, start a host with a scenario and connect a client station; verify client-side hardware sees `RunningScenario == 1`.
- Confirm existing hardware variables such as `Always`, `HasShip`, and ship-system variables still behave unchanged.
