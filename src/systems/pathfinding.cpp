#include "systems/pathfinding.h"
#include "components/avoidobject.h"
#include "components/collision.h"
#include "ecs/query.h"
#include "glm/gtx/norm.hpp"
#include <math.h>

const float small_object_grid_size = 5000.0f;
const float small_object_max_size = 1000.0f;
static PathFindingSystem* path_finding_system;


static uint32_t hashPosition(glm::vec2 position)
{
    uint32_t x = std::floor(position.x / small_object_grid_size);
    uint32_t y = std::floor(position.y / small_object_grid_size);
    return x ^ (y << 16);
}

PathFindingSystem::PathFindingSystem()
{
    path_finding_system = this;
}

void PathFindingSystem::update(float delta)
{
    // Remove any entities that where destroyed.
    big_entities.erase(std::remove_if(big_entities.begin(), big_entities.end(), [](sp::ecs::Entity e) { return !bool(e); } ), big_entities.end());
    for(auto it : small_entities)
        it.second.erase(std::remove_if(it.second.begin(), it.second.end(), [](sp::ecs::Entity e) { return !bool(e); } ), it.second.end());

    for(auto [entity, dao] : sp::ecs::Query<DelayedAvoidObject>()) {
        dao.delay -= delta;
        if (dao.delay <= 0.0f) {
            entity.addComponent<AvoidObject>().range = dao.range;
            entity.removeComponent<DelayedAvoidObject>();
        }
    }

    // Update big and small object lists.
    for(auto [entity, ao, transform] : sp::ecs::Query<AvoidObject, sp::Transform>()) {
        switch(ao.state) {
        case AvoidObject::InternalState::New:
            if (ao.range > small_object_max_size) {
                big_entities.push_back(entity);
                ao.state = AvoidObject::InternalState::BigEntity;
            } else {
                ao.position_hash = hashPosition(transform.getPosition());
                small_entities[ao.position_hash].push_back(entity);
                ao.state = AvoidObject::InternalState::SmallEntity;
            }
            break;
        case AvoidObject::InternalState::BigEntity:
            break;
        case AvoidObject::InternalState::SmallEntity:
            if (ao.position_hash != hashPosition(transform.getPosition())) {
                auto& so = small_entities[ao.position_hash];
                so.erase(std::remove_if(so.begin(), so.end(), [oe=entity](sp::ecs::Entity e) { return e == oe; } ), so.end());
                ao.position_hash = hashPosition(transform.getPosition());
                small_entities[ao.position_hash].push_back(entity);
            }
            break;
        }
    }
}


PathPlanner::PathPlanner()
{
}

void PathPlanner::plan(float my_radius, glm::vec2 start, glm::vec2 end)
{
    my_size = my_radius;

    if (route.size() == 0 || glm::length(route.back() - end) > 2000)
    {
        route.clear();
        int recursion_counter = 0;
        recursivePlan(start, end, recursion_counter);
        route.push_back(end);

        insert_idx = 0;
        remove_idx = 1;
        remove_idx2 = 1;
    }else{
        route.back() = end;

        glm::vec2 p0 = start;
        if (insert_idx < route.size())
        {
            if (insert_idx > 0)
                p0 = route[insert_idx - 1];
            glm::vec2 p1 = route[insert_idx];

            glm::vec2 new_point{};
            if (checkToAvoid(p0, p1, new_point))
            {
                route.insert(route.begin() + insert_idx, new_point);
            }
            insert_idx++;
        }else if (remove_idx < route.size())
        {
            if (remove_idx > 1)
                p0 = route[remove_idx - 2];
            glm::vec2 p1 = route[remove_idx];
            glm::vec2 new_position{};
            glm::vec2 alt_position{};
            if (!checkToAvoid(p0, p1, new_position, &alt_position))
            {
                route.erase(route.begin() + remove_idx - 1);
            }else{
                if (glm::length2(route[remove_idx-1] - new_position) > 200.0f*200.0f && glm::length2(route[remove_idx-1] - alt_position) > 200.0f * 200.0f)
                    route[remove_idx-1] = new_position;
                remove_idx++;
            }
        }else if (remove_idx2 < route.size())
        {
            glm::vec2 new_point{};
            glm::vec2 p1 = route[remove_idx2];
            if (!checkToAvoid(p0, p1, new_point))
            {
                route.erase(route.begin(), route.begin() + remove_idx2);
            }else{
                remove_idx2++;
            }
        }else{
            insert_idx = 0;
            remove_idx = 1;
            remove_idx2 = 1;
        }
    }
}

void PathPlanner::clear()
{
    route.clear();
}

void PathPlanner::recursivePlan(glm::vec2 start, glm::vec2 end, int& recursion_counter)
{
    glm::vec2 new_point{};
    if (recursion_counter < 100 && checkToAvoid(start, end, new_point))
    {
        recursion_counter += 1;
        recursivePlan(start, new_point, recursion_counter);
        recursivePlan(new_point, end, recursion_counter);
    }else{
        route.push_back(end);
    }
}

bool PathPlanner::checkToAvoid(glm::vec2 start, glm::vec2 end, glm::vec2& new_point, glm::vec2* alt_point)
{
    glm::vec2 startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    if (startEndLength < 100.0f)
        return false;
    float firstAvoidF = startEndLength;
    sp::ecs::Entity avoidObject;
    glm::vec2 firstAvoidQ{};

    for(auto e : path_finding_system->big_entities)
    {
        auto ao = e.getComponent<AvoidObject>();
        auto transform = e.getComponent<sp::Transform>();
        if (ao && transform)
        {
            auto position = transform->getPosition();
            float f = glm::dot(startEndDiff, position - start) / startEndLength;
            if (f > 0 && f < startEndLength - ao->range)
            {
                glm::vec2 q = start + startEndDiff / startEndLength * f;
                if (glm::length2(q - position) < (ao->range + my_size) * (ao->range + my_size))
                {
                    if (f < firstAvoidF)
                    {
                        avoidObject = e;
                        firstAvoidF = f;
                        firstAvoidQ = q;
                    }
                }
            }
        }
    }

    {
        // Bresenham's line algorithm to
        int x1 = std::floor(start.x / small_object_grid_size);
        int y1 = std::floor(start.y / small_object_grid_size);
        int x2 = std::floor(end.x / small_object_grid_size);
        int y2 = std::floor(end.y / small_object_grid_size);

        const bool steep = abs(y2 - y1) > abs(x2 - x1);
        if(steep)
        {
            std::swap(x1, y1);
            std::swap(x2, y2);
        }

        if(x1 > x2)
        {
            std::swap(x1, x2);
            std::swap(y1, y2);
        }

        const int dx = x2 - x1;
        const int dy = abs(y2 - y1);

        int error = dx / 2;
        const int ystep = (y1 < y2) ? 1 : -1;
        int y = y1;

        for(int x=x1; x<=x2; x++)
        {
            uint32_t hash;
            if(steep)
            {
                hash = hashPosition({y * small_object_grid_size, x * small_object_grid_size});
            }
            else
            {
                hash = hashPosition({x * small_object_grid_size, y * small_object_grid_size});
            }

            for(auto e : path_finding_system->small_entities[hash])
            {
                auto ao = e.getComponent<AvoidObject>();
                auto transform = e.getComponent<sp::Transform>();
                if (ao && transform)
                {
                    glm::vec2 position = transform->getPosition();
                    float f = glm::dot(startEndDiff, position - start) / startEndLength;
                    if (f > 0 && f < startEndLength - ao->range)
                    {
                        glm::vec2 q = start + startEndDiff / startEndLength * f;
                        if (glm::length2(q - position) < (ao->range + my_size) * (ao->range + my_size))
                        {
                            if (f < firstAvoidF)
                            {
                                avoidObject = e;
                                firstAvoidF = f;
                                firstAvoidQ = q;
                            }
                        }
                    }
                }
            }

            error -= dy;
            if(error < 0)
            {
                y += ystep;
                error += dx;
            }
        }
    }

    if (firstAvoidF < startEndLength)
    {
        auto ao = avoidObject.getComponent<AvoidObject>();
        auto transform = avoidObject.getComponent<sp::Transform>();

        glm::vec2 position = transform->getPosition();
        if (firstAvoidQ.x == position.x && firstAvoidQ.y == position.y)
            firstAvoidQ.x += 0.1f;
        new_point = position + glm::normalize(firstAvoidQ - position) * (ao->range * 1.1f + my_size);
        if (alt_point)
            *alt_point = position - glm::normalize(firstAvoidQ - position) * (ao->range * 1.1f + my_size);
        return true;
    }
    return false;
}
