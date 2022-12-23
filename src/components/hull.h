#pragma once

#include "scriptInterface.h"
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

    ScriptSimpleCallback on_destruction;
    ScriptSimpleCallback on_taking_damage;
};
