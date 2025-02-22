#pragma once

#include "ecs/entity.h"
#include <cmath>

//Base class for ship systems, ever created directly, use as base class for other components.
class ShipSystem
{
public:
    enum class Type
    {
        None = -1,
        Reactor = 0,
        BeamWeapons,
        MissileSystem,
        Maneuver,
        Impulse,
        Warp,
        JumpDrive,
        FrontShield,
        RearShield,
        COUNT
    };
    static constexpr int COUNT = static_cast<int>(Type::COUNT);

    static constexpr float power_factor_rate = 0.08f;
    static constexpr float default_add_heat_rate_per_second = 0.05f;
    static constexpr float default_power_rate_per_second = 0.3f;
    static constexpr float default_coolant_rate_per_second = 1.2f;

    float health = 1.0f; //1.0-0.0, where 0.0 is fully broken.
    float health_max = 1.0f; //1.0-0.0, where 0.0 is fully broken.
    float power_level = 1.0f; //0.0-3.0, default 1.0
    float power_request = 1.0f;
    float heat_level = 0.0f; //0.0-1.0, system will damage at 1.0
    float coolant_level = 0.0f; //0.0-10.0
    float coolant_request = 0.0f;
    bool can_be_hacked = true;
    float hacked_level = 0.0f; //0.0-1.0
    float power_factor = 1.0f;
    float coolant_change_rate_per_second = default_coolant_rate_per_second;
    float heat_add_rate_per_second = default_add_heat_rate_per_second;
    float power_change_rate_per_second = default_power_rate_per_second;
    float auto_repair_per_second = 0.0f;

    float getSystemEffectiveness();
    void addHeat(float amount);

    float getHeatingDelta() const
    {
        return std::pow(1.7f, power_level - 1.0f) - (1.01f + coolant_level * 0.1f);
    }

    static ShipSystem* get(sp::ecs::Entity entity, Type type);
};

string getSystemName(ShipSystem::Type system);
string getLocaleSystemName(ShipSystem::Type system);
