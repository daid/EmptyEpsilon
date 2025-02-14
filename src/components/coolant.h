#pragma once

// The coolant component interacts heavily with the ShipComponents.
//  An important aspect is that if this component exists, the ShipComponents will interact with coolant and heat.
class Coolant
{
public:
    float max = 10.0f;
    float max_coolant_per_system = 10.0f;
    bool auto_levels = false;
};