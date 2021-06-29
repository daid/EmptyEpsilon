#ifndef PARTICLE_EFFECT_H
#define PARTICLE_EFFECT_H

#include <SFML/System/Vector3.hpp>
#include <SFML/Graphics.hpp>

#include "engine.h"

#include "glObjects.h"

struct ParticleData
{
    sf::Vector3f position{};
    sf::Vector3f color{};
    float size{};
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

#if FEATURE_3D_RENDERING
    static constexpr size_t vertices_per_instance = 4; // a quad...
    static constexpr size_t elements_per_instance = 6; // ... made of two triangles (ES2 has no support for GL_QUADS)
    static constexpr size_t instances_per_draw = (std::numeric_limits<uint8_t>::max() + 1) / vertices_per_instance; // Number of particles that a single draw can handle.
    static constexpr size_t max_vertex_count = instances_per_draw * vertices_per_instance; // Maximum number of vertices per draw call.

    enum class Uniforms : uint8_t
    {
        Projection = 0,
        ModelView,

        Count
    };

    enum class Buffers : uint8_t
    {
        Element = 0,
        Vertex,

        Count
    };

    enum class Attributes : uint8_t
    {
        Center = 0,
        TexCoords,
        Color,
        Size,

        Count
    };
#endif

public:
    static void render();
    virtual void update(float delta);

    static void spawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time);

private:
#if FEATURE_3D_RENDERING
    ParticleEngine();
    void doRender();
    void doSpawn(sf::Vector3f position, sf::Vector3f end_position, sf::Vector3f color, sf::Vector3f end_color, float size, float end_size, float life_time);

    std::array<uint32_t, static_cast<size_t>(Uniforms::Count)> uniforms;
    std::array<uint32_t, static_cast<size_t>(Attributes::Count)> attributes{};
    gl::Buffers<static_cast<size_t>(Buffers::Count)> buffers{ gl::Unitialized{} };

    std::vector<Particle> particles;
    std::vector<Particle>::iterator first_expired;
    
    sf::Shader* shader = nullptr;
#endif
};

#endif//PARTICLE_EFFECT_H
