#pragma once

#include "ecs/entity.h"
#include "shipsystem.h"


class Shields {
public:
    static constexpr size_t max_count = 8;

    bool active = true;

    // Time in seconds it takes to recalibrate shields
    float calibration_time = 25.0f;
    float calibration_delay = 0.0f;
    int frequency = -1; // Current frequency of the shield. -1 indicates that these shields have no frequency.

    float energy_use_per_second = 1.5f;

    int count = 0;
    struct Shield {
        float level = 0.0f;
        float max = 0.0f;
        float hit_effect = 0.0f;
    };
    Shield entry[max_count];
    ShipSystem front_system;
    ShipSystem rear_system;

    ShipSystem& getSystemForIndex(int index);
    float getDamageFactor(int index);
};
