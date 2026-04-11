#pragma once

#include <stdint.h>

// Component to indicate that this entity should be avoided by path planning.
class AvoidObject
{
public:
    AvoidObject() = default;
    AvoidObject(float range) : range(std::max(0.0f, range)) {}

    // Internal state used by the pathfinding system.
    enum class InternalState {
        New,
        BigEntity,
        SmallEntity,
    } state = InternalState::New;
    uint32_t position_hash = 0;

    void setRange(float range) { this->range = std::max(0.0f, range); }
    float getRange() const { return this->range; }
private:
    float range = 100.0f;
};

class DelayedAvoidObject
{
public:
    DelayedAvoidObject() = default;
    DelayedAvoidObject(float delay, float range) : delay(delay), range(std::max(0.0f, range)) {}

    float delay = 10.0f;

    void setRange(float range) { this->range = std::max(0.0f, range); }
    float getRange() const { return this->range; }
private:
    float range = 100.0f;
};
