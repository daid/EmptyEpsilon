#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include <glm/vec2.hpp>


class WarpSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static bool isWarpJammed(sp::ecs::Entity);
    static glm::vec2 getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end);
};
