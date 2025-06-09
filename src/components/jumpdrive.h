#pragma once

#include "stringImproved.h"
#include "shipsystem.h"
#include "tween.h"

// Jump drive component provides the entity with the ability to teleport a specified distance forward
class JumpDrive : public ShipSystem {
public:
    // Config
    float charge_time = 90.0f; //[config] Total time to recharge the jump drive after jumping jump.max_distance mU
    float energy_per_u_charge = 2.0f; //[config] Amount of reactor energy to consume per U of jump.distance
    float heat_per_jump = 0.35f; //[config] Flat amount of jump system heat to generate per jump, regardless of distance
    float min_distance = 5000.0f; //[config] Minimum configured jump distance in mU
    float max_distance = 50000.0f; //[config] Maximum configured jump distance in mU, which also sets maximum jump.charge value
    float activation_delay = 10.0f; //[config] Default seconds between initiating a jump and jumping with nominal jump system effectiveness

    // Runtime
    float charge = 50000.0f; //[output] Current jump drive charge, limited by jump.max_distance
    float distance = 0.0f; //[output] Configured jump distance in mU
    float activation_rate = 1.0f; //[output] Effective rate before activating an initiated jump, in amount of jump.delay consumed per tick
    float delay = 0.0f; //[output] Remaining delay relative to jump.activation_delay, independent of system effectiveness. When 0.0, an in-progress jump is activated and the entity teleports. This value calculates the jump's activation and is also used by CPUShip AI and hardware
    float effective_activation_delay = activation_delay; //[output] Real-clock seconds remaining before completing an initated jump, as modified by jump.delay progress and system effectiveness. This value is used in UI
    float just_jumped = 0.0f; //[output] Used for visual effect after jumping

    // Returns the jump drive's recharge rate based on its system effectiveness
    float get_recharge_rate() { return Tween<float>::linear(getSystemEffectiveness(), 0.0, 1.0, -0.25, 1.0); }
};