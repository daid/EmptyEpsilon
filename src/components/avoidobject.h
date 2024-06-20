#pragma once

#include <stdint.h>


// Component to indicate that this entity should be avoided by path planning.
class AvoidObject
{
public:
    float range = 100.0f;

    // Internal state used by the pathfinding system.
    enum class InternalState {
        New,
        BigEntity,
        SmallEntity,
    } state = InternalState::New;
    uint32_t position_hash = 0;
};

class DelayedAvoidObject
{
public:
    float delay = 10.0f;
    float range = 100.0f;
};