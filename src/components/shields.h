#pragma once

#include "ecs/entity.h"
#include "shipsystem.h"


class Shields {
public:
    bool active = true;

    // Time in seconds it takes to recalibrate shields
    float calibration_time = 25.0f;
    float calibration_delay = 0.0f;
    int frequency = -1; // Current frequency of the shield. -1 indicates that these shields have no frequency.

    float energy_use_per_second = 1.5f;

    struct Shield {
        float level = 1.0f;
        float max = 1.0f;
        float hit_effect = 0.0f;

        int percentage() { if (max <= 0.0f) return 0; return int(100.0f * level / max); }
    };
    std::vector<Shield> entries;
    ShipSystem front_system;
    ShipSystem rear_system;

    ShipSystem& getSystemForIndex(int index);
    float getDamageFactor(int index);
};
