#pragma once

#include "io/dataBuffer.h"

#include "graphics/texture.h"
#include "mesh.h"
#include "shaderRegistry.h"


class MeshRenderComponent
{
public:
    string mesh_name;
    string texture_name;
    string specular_texture_name;
    string illumination_texture_name;
    glm::vec3 mesh_offset{};
    float scale;
};
