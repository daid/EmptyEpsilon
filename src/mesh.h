#ifndef MESH_H
#define MESH_H

#include <SFML/System.hpp>
#include "stringImproved.h"

class MeshVertex
{
public:
    float position[3];
    float normal[3];
    float uv[2];
};

class Mesh : public sf::NonCopyable
{
    int vertexCount;
    MeshVertex* vertices;
    unsigned int vbo;

    Mesh();
public:
    Mesh(std::vector<MeshVertex>& vertices);
    ~Mesh();
    
    void render();
    sf::Vector3f randomPoint();

    static Mesh* getMesh(string filename);
};

#endif//MESH_H
