#pragma once

#include "ecs/system.h"
#include "ecs/query.h"
#include "components/shipsystem.h"


class ShipSystemsSystem : public sp::ecs::System
{
public:
    constexpr static float unhack_time = 180.0f; //It takes this amount of time to go from 100% hacked to 0% hacked for systems.

    void update(float delta) override;
private:
    void updateSystem(ShipSystem& system, float delta, bool has_coolant);
};
