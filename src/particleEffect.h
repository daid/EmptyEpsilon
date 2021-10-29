#ifndef PARTICLE_EFFECT_H
#define PARTICLE_EFFECT_H

#include "Updatable.h"
#include "graphics/shader.h"

#include "glObjects.h"

#include <glm/vec3.hpp>
#include <glm/mat4x4.hpp>

struct ParticleData
{
    glm::vec3 position{};
    glm::vec3 color{};
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

    static constexpr size_t vertices_per_instance = 4; // a quad...
    static constexpr size_t elements_per_instance = 6; // ... made of two triangles (ES2 has no support for GL_QUADS)
    static constexpr size_t instances_per_draw = (std::numeric_limits<uint16_t>::max() + 1) / vertices_per_instance; // Number of particles that a single draw can handle.
    static constexpr size_t max_vertex_count = instances_per_draw * vertices_per_instance; // Maximum number of vertices per draw call.

    enum class Uniforms : uint8_t
    {
        Projection = 0,
        View,

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

public:
    static void render(const glm::mat4& projection, const glm::mat4& view);
    virtual void update(float delta) override;

    static void spawn(glm::vec3 position, glm::vec3 end_position, glm::vec3 color, glm::vec3 end_color, float size, float end_size, float life_time);

private:
    ParticleEngine();
    void doRender(const glm::mat4& projection, const glm::mat4& view);
    void doSpawn(glm::vec3 position, glm::vec3 end_position, glm::vec3 color, glm::vec3 end_color, float size, float end_size, float life_time);
    void initialize();

    std::array<uint32_t, static_cast<size_t>(Uniforms::Count)> uniforms;
    std::array<uint32_t, static_cast<size_t>(Attributes::Count)> attributes{};
    gl::Buffers<static_cast<size_t>(Buffers::Count)> buffers{ gl::Unitialized{} };

    std::vector<Particle> particles;
    std::vector<Particle>::iterator first_expired;
    
    std::vector<ParticleData> particles_renderdata;
    sp::Shader* shader = nullptr;
};

#endif//PARTICLE_EFFECT_H
