#pragma once

#include <ecs/entity.h>
#include <glm/vec3.hpp>
#include "systems/damage.h"


class MissileFlight
{
public:
    float speed;
};

class MissileHoming
{
public:
    float turn_rate;
    float range;
    sp::ecs::Entity target;
    float target_angle;
};

class MissileCollision
{
public:
    float damage_at_center;
    float damage_at_edge;
    float blast_range;
    sp::ecs::Entity owner;
    DamageType damage_type = DamageType::Kinetic;
    string explosion_sfx;
};

//TODO: Not really part of missile.h
class ConstantParticleEmitter
{
public:
    float interval = 0.1f;
    float delay = 0.0f;

    glm::vec3 start_color = glm::vec3(1, 0.8, 0.8);
    glm::vec3 end_color = glm::vec3(0, 0, 0);
    float start_size = 5.0f;
    float end_size = 20.0f;
    float life_time = 5.0f;
};

//TODO: Not really part of missile.h
class LifeTime
{
public:
    float lifetime = 1.0f;
};
