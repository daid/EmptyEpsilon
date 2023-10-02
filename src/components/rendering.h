#pragma once

#include "io/dataBuffer.h"

#include "graphics/texture.h"
#include "mesh.h"
#include "shaderRegistry.h"

struct MeshRef
{
    string name;
    Mesh* ptr = nullptr;
};
struct TextureRef
{
    string name;
    sp::Texture* ptr = nullptr;
};

class MeshRenderComponent
{
public:
    MeshRef mesh;
    TextureRef texture;
    TextureRef specular_texture;
    TextureRef illumination_texture;
    glm::vec3 mesh_offset{};
    float scale;
};

class EngineEmitter
{
public:
    float last_engine_particle_time = 0.0f;

    struct Emitter {
        glm::vec3 position{};
        glm::vec3 color{};
        float scale;
    };
    std::vector<Emitter> emitters;
};

class NebulaRenderer
{
public:
    struct Cloud
    {
        glm::vec2 offset{0, 0};
        TextureRef texture;
        float size = 512.0f;
    };

    std::vector<Cloud> clouds;
};

// Renders a beam from the source to the target, used for beam weapons but can also be used for other visual effects.
class BeamRenderer
{
public:
    float lifetime;
    sp::ecs::Entity source;
    sp::ecs::Entity target;
    glm::vec3 source_offset{};
    glm::vec3 target_offset{};
    glm::vec2 target_location{};
    TextureRef texture;
};

// Renders a single quad texture as "hit effect" of beam weapons.
class HitRingRenderer
{
public:
    sp::ecs::Entity target;
    glm::vec2 target_location{};
    glm::vec3 target_offset{};
    glm::vec3 hit_normal{};
    TextureRef texture;
};
