#pragma once

#include "shipsystem.h"

// The reactor component stores and generates energy, any shipsystem can use energy and drain this. While the reactor generates energy.
class Reactor : public ShipSystem {
public:
    // Config
    float max_energy = 1000.0f;

    // Runtime
    float energy = 1000.0f;

    bool use_energy(float amount) { if (amount > energy) return false; energy -= amount; return true; }
};