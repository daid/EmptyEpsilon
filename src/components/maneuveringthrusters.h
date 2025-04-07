#pragma once

#include "shipsystem.h"
#include <limits>


class ManeuveringThrusters : public ShipSystem {
public:
    // Config
    float speed = 10.0f; // [config] Speed of rotation, in deg/second

    // Runtime
    float target = std::numeric_limits<float>::min(); // [input] Ship will try to aim to this rotation. (degrees)
    float rotation_request = std::numeric_limits<float>::min(); // [input] Ship will rotate in this velocity. ([-1,1], overrides target_rotation)

    void stop() { target = std::numeric_limits<float>::min(); rotation_request = std::numeric_limits<float>::min(); }
};

class CombatManeuveringThrusters {
public:
    float charge_time = 20.0f; // time to charge from 0 to 100%, assuming we have both impulse and maneuver systems.
    float charge = 1.0f; // [output] How much charge there is in the combat maneuvering system (0.0-1.0)

    struct Thruster {
        float request = 0.0f; // [input] How much boost we want at this moment (0.0-1.0)
        float active = 0.0f;
        float speed = 0.0f; /*< [config] Speed to indicate how fast we will fly forwards/sideways with a full boost/strafe */
        float max_time = 3.0f; // max time to boost with a fully charged system
        float heat_per_second = 0.2f; // heat per second when fully active
    };
    Thruster boost;
    Thruster strafe;
};
