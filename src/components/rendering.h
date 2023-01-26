#pragma once

#include "io/dataBuffer.h"

#include "graphics/texture.h"
#include "mesh.h"
#include "shaderRegistry.h"


class MeshRenderComponent
{
public:
    string mesh;
    string texture;
    string specular_texture;
    string illumination_texture;
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
