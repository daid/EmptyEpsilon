#ifndef MESH_H
#define MESH_H

#include "nonCopyable.h"
#include "stringImproved.h"
#include "glObjects.h"

#include <glm/vec3.hpp>

struct MeshVertex
{
    float position[3];
    float normal[3];
    float uv[2];
};

class Mesh : sp::NonCopyable
{
    std::vector<MeshVertex> vertices;
    std::vector<uint16_t> indices;
    gl::Buffers<2> vbo_ibo{ gl::Unitialized{} };
    uint32_t face_count{};
public:
    float greatest_distance_from_center{};
    explicit Mesh(std::vector<MeshVertex>&& vertices);

    void render(int32_t position_attrib, int32_t texcoords_attrib, int32_t normal_attrib);
    glm::vec3 randomPoint();

    // Calculate the center all vertices in this mesh, and return the distance
    // of the point farthest from that center.
    uint32_t greatestDistanceFromCenter(std::vector<MeshVertex>& vertices);

    static Mesh* getMesh(const string& filename);
};

#endif//MESH_H
