#pragma once

#include "ecs/entity.h"
#include "ecs/system.h"
#include "components/shipsystem.h"


enum class DamageType
{
    Energy,
    Kinetic,
    EMP
};

class DamageInfo
{
public:
    sp::ecs::Entity instigator;
    DamageType type;
    glm::vec2 location{0, 0};
    int frequency = 0;
    ShipSystem::Type system_target;

    DamageInfo()
    : instigator(), type(DamageType::Energy), location(0, 0), frequency(-1), system_target(ShipSystem::Type::None)
    {}

    DamageInfo(sp::ecs::Entity instigator, DamageType type, glm::vec2 location)
    : instigator(instigator), type(type), location(location), frequency(-1), system_target(ShipSystem::Type::None)
    {}
};


class DamageSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static void damageArea(glm::vec2 position, float blast_range, float min_damage, float max_damage, const DamageInfo& info, float min_range);
    static void applyDamage(sp::ecs::Entity entity, float amount, const DamageInfo& info);

private:
    static void takeHealthDamage(sp::ecs::Entity entity, float amount, const DamageInfo& info);
    static void destroyedByDamage(sp::ecs::Entity entity, const DamageInfo& info);
};
