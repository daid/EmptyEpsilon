#pragma once

#include "components/shipsystem.h"
#include <vector>

// Internal composition of a ship.
class InternalRooms
{
public:
    struct Room {
        glm::ivec2 position;
        glm::ivec2 size;
        ShipSystem::Type system = ShipSystem::Type::None;
    };
    struct Door {
        glm::ivec2 position;
        bool horizontal;
    };

    std::vector<Room> rooms;
    std::vector<Door> doors;

    glm::ivec2 roomMin();
    glm::ivec2 roomMax();
    ShipSystem::Type getSystemAtRoom(glm::ivec2 pos);

    bool auto_repair_enabled = false; // Repair crew with auto target damaged rooms
};

class InternalCrew
{
public:
    enum class Action
    {
        Idle,
        Move
    };
    enum class Direction
    {
        None,
        Up,
        Down,
        Left,
        Right
    };

    float move_speed = 2.0f;
    glm::vec2 position{-1,-1};
    glm::ivec2 target_position{0,0};
    Action action = Action::Idle;
    Direction direction = Direction::None;
    float action_delay = 0.0f;
    sp::ecs::Entity ship;
};

class InternalRepairCrew
{
public:
    float repair_per_second = 0.007;
    float unhack_per_second = 0.007;
};
