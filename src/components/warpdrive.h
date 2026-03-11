#pragma once

#include "stringImproved.h"
#include "shipsystem.h"

// Warp drive component grants this entity high-speed warp propulsion.
class WarpDrive : public ShipSystem
{
public:
    // Config
    float charge_time = 4.0f;
    float decharge_time = 2.0f;
    float heat_per_warp = 0.02f;
    int max_level = 4;
    float speed_per_level = 1000.0f;
    float energy_warp_per_second = 1.7f;

    // Runtime
    int request = 0; // [input] Requested warp factor, from 0 to max_level
    float current = 0.0f; // [output] Current active warp factor, from 0.0 to max_level
};

class WarpJammer
{
public:
    float range = 7000.0f;
};