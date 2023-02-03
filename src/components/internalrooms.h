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
