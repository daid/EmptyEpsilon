#pragma once

#include "script/callback.h"
#include "systems/damage.h"

// Component for entities that can take damage and be destroyed.
// This component tracks current and max health values for all damageable
// entities, and implements damage and destruction callbacks.
// Entities are typically destroyed if daamaged while at zero health.
// Destructability can be disabled to prevent player ship destruction in LARP
// scenarios or tutorials.
// 
// For UI display purposes, player-facing interfaces by default display the
// health of entities ONLY if they have both Health and Hull components.
// Entities that have only Health can be targeted but don't show health values
// in player UI.
class Health
{
private:
    float current = 100.0f;
    float max = 100.0f;
public:
    bool allow_destruction = true;
    int damaged_by_flags = (1 << int(DamageType::Energy)) | (1 << int(DamageType::Kinetic));
    float damage_indicator = 0.0f;  // Visual damage flash timer (1.5s)

    float getHealth() const { return current; }
    void setHealth(float value) { current = std::clamp(value, 0.0f, max); }
    float getHealthMax() const { return max; }
    void setHealthMax(float value) { max = std::max(0.0f, value); if (current > max) current = max; }

    sp::script::Callback on_destruction;
    sp::script::Callback on_taking_damage;
};

// Component indicates that an entity lacks a hull or health value, but an
// area damage effect (i.e. explosion) in the area still destroys it.
class DestroyedByAreaDamage
{
public:
    int damaged_by_flags = (1 << int(DamageType::Energy)) | (1 << int(DamageType::Kinetic));
};
