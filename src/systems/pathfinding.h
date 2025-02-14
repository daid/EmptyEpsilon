#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include <vector>
#include <unordered_map>


class PathFindingSystem : public sp::ecs::System
{
public:
    PathFindingSystem();
    void update(float delta) override;

private:
    std::vector<sp::ecs::Entity> big_entities;
    std::unordered_map<uint32_t, std::vector<sp::ecs::Entity> > small_entities;

    friend class PathPlanner;
};


//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner
{
private:
    unsigned int insert_idx, remove_idx, remove_idx2;
    float my_size = 0.0f;

public:
    PathPlanner();

    std::vector<glm::vec2> route;

    void plan(float my_radius, glm::vec2 start, glm::vec2 end);
    void clear();
private:
    void recursivePlan(glm::vec2 start, glm::vec2 end, int& recursion_counter);
    bool checkToAvoid(glm::vec2 start, glm::vec2 end, glm::vec2& new_point, glm::vec2* alt_point=NULL);
};
