#ifndef PARTICLE_EFFECT_H
#define PARTICLE_EFFECT_H

#include <SFML/System.hpp>
#include <SFML/Graphics.hpp>

#include "engine.h"

class ParticleData
{
public:
    sf::Vector3f position;
    sf::Vector3f color;
    float size;
};
class Particle
{
public:
    ParticleData start;
    ParticleData end;
    float life_time;
    float max_life_time;
};

class ParticleEngine : public Updatable
{
    static ParticleEngine* particleEngine;
    static std::vector<Particle> particles;
public:
    static void render();
    virtual void update(float delta);

    static void spawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time);
};

#endif//PARTICLE_EFFECT_H
