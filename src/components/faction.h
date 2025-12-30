#pragma once

#include "ecs/entity.h"
#include <glm/gtc/type_precision.hpp>
#include <vector>

class FactionInfo;

enum class FactionRelation
{
    None,      // Entity has no Faction component
    Friendly,
    Neutral,
    Enemy
};

// Component to set our current faction,
//  a faction is an entity with the FactionInfo component
class Faction
{
public:
    sp::ecs::Entity entity;

    static sp::ecs::Entity find(const string& name);
    static FactionInfo& getInfo(sp::ecs::Entity entity);
    static FactionRelation getRelation(sp::ecs::Entity a, sp::ecs::Entity b);

    static void didAnOffensiveAction(sp::ecs::Entity entity);
};

class FactionInfo
{
public:
    glm::u8vec4 gm_color = {255,255,255,255};
    string name;
    string locale_name;
    string description;

    float reputation_points = 0.0f;

    struct Relation {
        sp::ecs::Entity other_faction;
        FactionRelation relation;
    };
    bool relations_dirty = true;
    std::vector<Relation> relations;

    FactionRelation getRelation(sp::ecs::Entity faction_entity);
    void setRelation(sp::ecs::Entity faction_entity, FactionRelation relation);

    static FactionInfo* find(const string& name);
};
