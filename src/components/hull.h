#pragma once

#include "script/callback.h"
#include "systems/damage.h"


// Component to indicate that this entity has a hull and can get hull damage.
//  Usually entities are destroyed once they reach zero hull. But you can disable this to prevent player ship destruction in LARP scenarios or tutorials.
class Hull
{
public:
    float current = 100.0f;
    float max = 100.0f;
    bool allow_destruction = true;
    int damaged_by_flags = (1 << int(DamageType::Energy)) | (1 << int(DamageType::Kinetic));
    float damage_indicator = 0.0f;

    sp::script::Callback on_destruction;
    sp::script::Callback on_taking_damage;
};

// Not having actual hull, but an explosion in the area will destroy this entity.
class DestroyedByAreaDamage
{
public:
    int damaged_by_flags = (1 << int(DamageType::Energy)) | (1 << int(DamageType::Kinetic));
};