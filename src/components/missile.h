#pragma once

#include <ecs/entity.h>
#include <glm/vec3.hpp>
#include "systems/damage.h"


class MissileFlight
{
public:
    float speed=100.0f;
    float timeout=0.0f;
};

class MissileHoming
{
public:
    float turn_rate=1.0f;
    float range=100.0f;
    sp::ecs::Entity target;
    float target_angle = 0.0f;
};

//TODO: Not really part of missile.h, also part of asteroids
class ExplodeOnTouch
{
public:
    float damage_at_center = 35.0f;
    float damage_at_edge = 35.0f;
    float blast_range = 100.0f;
    sp::ecs::Entity owner;
    DamageType damage_type = DamageType::Kinetic;
    string explosion_sfx;
};
class ExplodeOnTimeout
{
};
class DelayedExplodeOnTouch : public ExplodeOnTouch
{
public:
    float delay = 1.0f;
    bool triggered = false;
};

//TODO: Not really part of missile.h
class ConstantParticleEmitter
{
public:
    float interval = 0.1f;
    float delay = 0.0f;

    float travel_random_range=0.0f;
    glm::vec3 start_color = glm::vec3(1, 0.8, 0.8);
    glm::vec3 end_color = glm::vec3(0, 0, 0);
    float start_size = 5.0f;
    float end_size = 20.0f;
    float life_time = 5.0f;
};
