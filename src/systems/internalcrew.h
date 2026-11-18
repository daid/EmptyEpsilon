#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include <glm/vec2.hpp>
#include <optional>


class InternalCrewSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    // Crew-stacking helpers. A cell counts as occupied if another crew member of the same ship
    // has it as its destination (target_position; an idle crew's target is the cell it stands on).
    // Only destinations are checked, not paths: a cell another crew is merely walking through is free.
    // Crews that have not been placed yet (position.x < -0.5) are ignored.
    // `ignore` is excluded from the check (the crew member being moved).
    static bool isCellOccupied(sp::ecs::Entity ship, glm::ivec2 cell, sp::ecs::Entity ignore);
    // Nearest unoccupied cell (inside any room of the ship) to `from`, or nullopt if every cell is taken
    // or the ship has no rooms. Ties go to the first cell in room/row order, so the result is deterministic.
    static std::optional<glm::ivec2> findNearestFreeCell(sp::ecs::Entity ship, glm::ivec2 from, sp::ecs::Entity ignore);
};
