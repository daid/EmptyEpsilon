#include "components/internalrooms.h"


glm::ivec2 InternalRooms::roomMin()
{
    if (rooms.empty())
        return {0, 0};
    auto min = rooms[0].position;
    for(const auto& r : rooms) {
        min.x = std::min(min.x, r.position.x);
        min.y = std::min(min.y, r.position.y);
    }
    return min;
}

glm::ivec2 InternalRooms::roomMax()
{
    if (rooms.empty())
        return {0, 0};
    auto max = rooms[0].position + rooms[0].size;
    for(const auto& r : rooms) {
        max.x = std::max(max.x, r.position.x + r.size.x);
        max.y = std::max(max.y, r.position.y + r.size.y);
    }
    return max;
}

ShipSystem::Type InternalRooms::getSystemAtRoom(glm::ivec2 pos)
{
    for(const auto& r : rooms) {
        if (pos.x >= r.position.x && pos.x < r.position.x + r.size.x && pos.y >= r.position.y && pos.y < r.position.y + r.size.y)
            return r.system;
    }
    return ShipSystem::Type::None;
}
