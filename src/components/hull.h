#pragma once

#include "script/callback.h"
#include "systems/damage.h"

// Component to indicate that this entity can take damage.
// An entity is typically destroyed once it reaches 0 health, but you can
// disable this to prevent an entity's destruction in LARP scenarios or
// tutorials.
class Health
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

// Component to indicate that this entity has a hull and can take hull damage.
// A hull functions as Health but represents a physical structure on an entity.
// Having a Hull makes an entity targetable, scannable, and selectable.
class Hull : public Health
{
};

// Not having actual hull, but an explosion in the area will destroy this entity.
class DestroyedByAreaDamage
{
public:
    int damaged_by_flags = (1 << int(DamageType::Energy)) | (1 << int(DamageType::Kinetic));
};