#pragma once

#include "ecs/entity.h"
#include <glm/vec2.hpp>

class ProbeSystem
{
public:
    // Spawn a probe from an entity with a ScanProbeLauncher, connect the
    // probe's AllowRadarLink to the launching entity, and launch it to the
    // target coordinates with MoveTo.
    static sp::ecs::Entity launch(sp::ecs::Entity ship, glm::vec2 target);
};
