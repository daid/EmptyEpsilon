#pragma once

//Base class for ship systems, ever created directly, use as base class for other components.
class ShipSystem
{
public:
    static constexpr float power_factor_rate = 0.08f;
    static constexpr float default_add_heat_rate_per_second = 0.05f;
    static constexpr float default_power_rate_per_second = 0.3f;
    static constexpr float default_coolant_rate_per_second = 1.2f;

    float health; //1.0-0.0, where 0.0 is fully broken.
    float health_max; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float power_request;
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0
    float coolant_request;
    float hacked_level; //0.0-1.0
    float power_factor;
    float coolant_change_rate_per_second = default_coolant_rate_per_second;
    float heat_add_rate_per_second = default_add_heat_rate_per_second;
    float power_change_rate_per_second = default_power_rate_per_second;

    float get_system_effectiveness();
    void add_heat(float amount);
};