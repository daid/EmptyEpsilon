#pragma once

#include "scriptInterface.h"


// Simple component that allows a callback when an entity is touched, and destroys the entity after the callback.
class PickupCallback
{
public:
    bool player = true; // Only check for PlayerControl entities.
    ScriptSimpleCallback callback;
};

// Simple component that allows a callback when an entity is touched
class CollisionCallback
{
public:
    bool player = true; // Only check for PlayerControl entities.
    ScriptSimpleCallback callback;
};
