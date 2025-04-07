#pragma once

#include "stringImproved.h"
#include "shipsystem.h"

// Impulse engine component, indicate that this entity can move under impulse control.
class WarpDrive : public ShipSystem {
public:
    // Config
    float charge_time = 4.0f;
    float decharge_time = 2.0f;
    float heat_per_warp = 0.02f;
    int max_level = 4;
    float speed_per_level = 1000;
    float energy_warp_per_second = 1.7f;

    // Runtime
    int request = 0; // [input] Level of warp requested, from 0 to max_level
    float current = 0.0f; // [output] Current active warp amount, from 0.0 to 4.0
};

class WarpJammer {
public:
    float range = 7000.0;
};