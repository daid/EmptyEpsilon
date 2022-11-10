#pragma once

#include "stringImproved.h"
#include "shipsystem.h"

// Impulse engine component, indicate that this entity can move under impulse control.
class ImpulseEngine : public ShipSystem {
public:
    // Config
    float max_speed_forward = 500.0f;  // in U/sec
    float max_speed_reverse = 500.0f;  // in U/sec
    float acceleration_forward = 20.0f;// in U/sec^2
    float acceleration_reverse = 20.0f;// in U/sec^2
    string sound;

    // Runtime
    float request = 0.0f; // -1.0 to 1.0
    float actual = 0.0f;  // -1.0 to 1.0
};