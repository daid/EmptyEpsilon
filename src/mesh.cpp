#include <SFML/OpenGL.hpp>
#include <map>
#include "engine.h"
#include "mesh.h"

static std::map<string, Mesh*> meshMap;

Mesh::Mesh()
{
    vertices = NULL;
    indices = NULL;
    vertexCount = 0;
}

Mesh::~Mesh()
{
    if (vertices) delete vertices;
    if (indices) delete indices;
}

void Mesh::render()
{
    glColor3f(1,1,1);
    glBegin(GL_TRIANGLES);
    for(int n=0; n<vertexCount; n++)
    {
        glTexCoord2f(vertices[n].uv[0], vertices[n].uv[1]);
        glNormal3f(vertices[n].normal[0], vertices[n].normal[1], vertices[n].normal[2]);
        glVertex3f(vertices[n].position[0], vertices[n].position[1], vertices[n].position[2]);
    }
    glEnd();
}

struct IndexInfo
{
    int v;
    int t;
    int n;
};

Mesh* Mesh::getMesh(string filename)
{
    Mesh* ret = meshMap[filename];
    if (ret)
        return ret;

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream)
        return NULL;
    
    std::vector<sf::Vector3f> vertices;
    std::vector<sf::Vector3f> normals;
    std::vector<sf::Vector2f> texCoords;
    std::vector<IndexInfo> indices;
    
    ret = new Mesh();
    do
    {
        string line = stream->readLine();
        if (line.length() > 0 && line[0] != '#')
        {
            std::vector<string> parts = line.split();
            if (parts[0] == "v")
            {
                vertices.push_back(sf::Vector3f(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat()));
            }else if (parts[0] == "vn")
            {
                normals.push_back(sf::normalize(sf::Vector3f(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat())));
            }else if (parts[0] == "vt")
            {
                texCoords.push_back(sf::Vector2f(parts[1].toFloat(), parts[2].toFloat()));
            }else if (parts[0] == "f")
            {
                for(unsigned int n=3; n<parts.size(); n++)
                {
                    std::vector<string> p0 = parts[1].split("/");
                    std::vector<string> p1 = parts[n].split("/");
                    std::vector<string> p2 = parts[n-1].split("/");
                    
                    IndexInfo info;
                    info.v = p0[0].toInt() - 1;
                    info.t = p0[1].toInt() - 1;
                    info.n = p0[2].toInt() - 1;
                    indices.push_back(info);
                    info.v = p1[0].toInt() - 1;
                    info.t = p1[1].toInt() - 1;
                    info.n = p1[2].toInt() - 1;
                    indices.push_back(info);
                    info.v = p2[0].toInt() - 1;
                    info.t = p2[1].toInt() - 1;
                    info.n = p2[2].toInt() - 1;
                    indices.push_back(info);
                }
            }else{
                //printf("%s\n", parts[0].c_str());
            }
        } 
    }while(stream->tell() < stream->getSize());
    ret->vertexCount = indices.size();
    ret->vertices = new MeshVertex[indices.size()];
    for(unsigned int n=0; n<indices.size(); n++)
    {
        ret->vertices[n].position[0] = vertices[indices[n].v].z;
        ret->vertices[n].position[1] = vertices[indices[n].v].x;
        ret->vertices[n].position[2] = vertices[indices[n].v].y;
        ret->vertices[n].normal[0] = normals[indices[n].n].z;
        ret->vertices[n].normal[1] = normals[indices[n].n].x;
        ret->vertices[n].normal[2] = normals[indices[n].n].y;
        ret->vertices[n].uv[0] = texCoords[indices[n].t].x;
        ret->vertices[n].uv[1] = 1.0 - texCoords[indices[n].t].y;
    }
    
    meshMap[filename] = ret;
    return ret;
}
