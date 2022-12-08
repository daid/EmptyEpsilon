#pragma once

#include "stringImproved.h"
#include "shipsystem.h"
#include "tween.h"

// Impulse engine component, indicate that this entity can move under impulse control.
class JumpDrive : public ShipSystem {
public:
    constexpr static float charge_time = 90.0f;   /*<Total charge time for the jump drive after a max range jump */
    constexpr static float energy_per_km_charge = 2.0f;
    constexpr static float heat_per_jump = 0.35f;

    // Config
    float min_distance = 5000.0f; //[config]
    float max_distance = 50000.0f; //[config]

    // Runtime
    float charge = 50000.0f; //[output]
    float distance = 0.0f;     //[output]
    float delay = 0.0f;        //[output]

    float get_recharge_rate() { return Tween<float>::linear(getSystemEffectiveness(), 0.0, 1.0, -0.25, 1.0); }
};