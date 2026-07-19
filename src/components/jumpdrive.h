#pragma once

#include "stringImproved.h"
#include "shipsystem.h"
#include "tween.h"

// Jump drive component indicates that this entity can teleport with a jump drive.
class JumpDrive : public ShipSystem {
public:
    // Config
    float charge_time = 90.0f;   /*<Total charge time for the jump drive after a max range jump */
    float energy_per_km_charge = 2.0f;
    float heat_per_jump = 0.35f;
    float min_distance = 5000.0f; //[config]
    float max_distance = 50000.0f; //[config]
    float activation_delay = 10.0f; // Time between hitting "jump" and actually jumping

    // Runtime
    float charge = 50000.0f; //[output]
    float distance = 0.0f;     //[output]
    float delay = 0.0f;        //[output]
    float just_jumped = 0.0f; //[output] used for visual effect after jumping.

    float get_recharge_rate() { return Tween<float>::linear(getSystemEffectiveness(), 0.0, 1.0, -0.25, 1.0); }
    int get_seconds_to_jump() {
        if (getSystemEffectiveness() <= 0.0f)
            return std::numeric_limits<int>::max();
        else
            return int(ceilf((activation_delay * (delay / activation_delay)) / getSystemEffectiveness()));
    }
};