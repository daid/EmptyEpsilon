#include "components/shields.h"
#include "vectorUtils.h"


ShipSystem& Shields::getSystemForIndex(int index)
{
    if (count < 2)
        return front_system;
    float angle = index * 360.0f / count;
    if (std::abs(angleDifference(angle, 0.0f)) < 90)
        return front_system;
    return rear_system;
}

float Shields::getDamageFactor(int index)
{
    auto system = getSystemForIndex(index);
    float shield_damage_exponent = 1.6f;
    float shield_damage_divider = 7.0f;
    float shield_damage_factor = 1.0f + powf(1.0f, shield_damage_exponent) / shield_damage_divider-powf(system.getSystemEffectiveness(), shield_damage_exponent) / shield_damage_divider;
    return shield_damage_factor;
}
