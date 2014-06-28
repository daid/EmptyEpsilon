#ifndef MESH_H
#define MESH_H

#include <SFML/System.hpp>

class MeshVertex
{
public:
    float position[3];
    float normal[3];
    float uv[2];
};

class Mesh : public sf::NonCopyable
{
    int vertex_count;
    MeshVertex* vertices;
    int16_t* indices;

    Mesh();
public:
    ~Mesh();

    void render();

    static Mesh* getMesh(string filename);
};

#endif//MESH_H
