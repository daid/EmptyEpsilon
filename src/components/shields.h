#pragma once

#include "ecs/entity.h"
#include "shipsystem.h"


class Shields {
public:
    static constexpr size_t max_count = 8;

    bool active = true;
    int frequency = -1; // Current frequency of the shield. -1 indicates that these shields have no frequency.

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
};
