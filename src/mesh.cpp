#include <graphics/opengl.h>
#include <unordered_map>
#include <SDL_endian.h>

#include "engine.h"
#include "mesh.h"

namespace
{
    inline int32_t readInt(const P<ResourceStream>& stream)
    {
        int32_t ret = 0;
        stream->read(&ret, sizeof(int32_t));
        return SDL_SwapBE32(ret);
    }

    constexpr uint32_t NO_BUFFER = 0;
    std::unordered_map<string, Mesh*> meshMap;
}
Mesh::Mesh(std::vector<MeshVertex>&& vertices)
    :vertices{vertices}, vbo{NO_BUFFER}
{
    if (!vertices.empty())
    {
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(MeshVertex) * vertices.size(), vertices.data(), GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
    }
}

Mesh::~Mesh()
{
    if (vbo != NO_BUFFER)
        glDeleteBuffers(1, &vbo);
}

void Mesh::render(int32_t position_attrib, int32_t texcoords_attrib, int32_t normal_attrib)
{
    if (vertices.empty())
        return;

    if (vbo != NO_BUFFER)
        glBindBuffer(GL_ARRAY_BUFFER, vbo);

    if (position_attrib != -1)
        glVertexAttribPointer(position_attrib, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, position));
    
    if (normal_attrib != -1)
        glVertexAttribPointer(normal_attrib, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, normal));
    
    if (texcoords_attrib != -1)
        glVertexAttribPointer(texcoords_attrib, 2, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, uv));

    glDrawArrays(GL_TRIANGLES, 0, vertices.size());

    if (vbo != NO_BUFFER)
        glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
}

glm::vec3 Mesh::randomPoint()
{
    if (vertices.empty())
        return glm::vec3{};

    //int idx = irandom(0, vertexCount-1);
    //return glm::vec3(vertices[idx].position[0], vertices[idx].position[1], vertices[idx].position[2]);
    // Pick a face
    int idx = irandom(0, vertices.size() / 3 - 1) * 3; 
    glm::vec3 v0 = glm::vec3(vertices[idx].position[0], vertices[idx].position[1], vertices[idx].position[2]);
    glm::vec3 v1 = glm::vec3(vertices[idx+1].position[0], vertices[idx+1].position[1], vertices[idx+1].position[2]);
    glm::vec3 v2 = glm::vec3(vertices[idx+2].position[0], vertices[idx+2].position[1], vertices[idx+2].position[2]);

    float f1 = random(0.0, 1.0);
    float f2 = random(0.0, 1.0);
    if (f1 + f2 > 1.0f)
    {
        f1 = 1.0f - f1;
        f2 = 1.0f - f2;
    }
    glm::vec3 v01 = (v0 * f1) + (v1 * (1.0f - f1));
    glm::vec3 ret = (v01 * f2) + (v2 * (1.0f - f2));
    return ret;
}

struct IndexInfo
{
    int v;
    int t;
    int n;
};

Mesh* Mesh::getMesh(const string& filename)
{
    Mesh* ret = meshMap[filename];
    if (ret)
        return ret;

    P<ResourceStream> stream = getResourceStream(filename);
    if (!stream)
        return NULL;

    std::vector<MeshVertex> mesh_vertices;
    if (filename.endswith(".obj"))
    {
        std::vector<glm::vec3> vertices;
        std::vector<glm::vec3> normals;
        std::vector<glm::vec2> texCoords;
        std::vector<IndexInfo> indices;

        do
        {
            string line = stream->readLine();
            if (line.length() > 0 && line[0] != '#')
            {
                std::vector<string> parts = line.strip().split();
                if (parts.size() < 1)
                    continue;
                if (parts[0] == "v")
                {
                    vertices.emplace_back(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat());
                }else if (parts[0] == "vn")
                {
                    normals.push_back(glm::normalize(glm::vec3(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat())));
                }else if (parts[0] == "vt")
                {
                    texCoords.push_back(glm::vec2(parts[1].toFloat(), parts[2].toFloat()));
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
                        info.v = p2[0].toInt() - 1;
                        info.t = p2[1].toInt() - 1;
                        info.n = p2[2].toInt() - 1;
                        indices.push_back(info);
                        info.v = p1[0].toInt() - 1;
                        info.t = p1[1].toInt() - 1;
                        info.n = p1[2].toInt() - 1;
                        indices.push_back(info);
                    }
                }else{
                    //printf("%s\n", parts[0].c_str());
                }
            }
        }while(stream->tell() < stream->getSize());

        
        mesh_vertices.resize(indices.size());
        for(unsigned int n=0; n<indices.size(); n++)
        {
            mesh_vertices[n].position[0] = vertices[indices[n].v].x;
            mesh_vertices[n].position[1] = vertices[indices[n].v].z;
            mesh_vertices[n].position[2] = vertices[indices[n].v].y;
            mesh_vertices[n].normal[0] = normals[indices[n].n].x;
            mesh_vertices[n].normal[1] = normals[indices[n].n].z;
            mesh_vertices[n].normal[2] = normals[indices[n].n].y;
            mesh_vertices[n].uv[0] = texCoords[indices[n].t].x;
            mesh_vertices[n].uv[1] = 1.f - texCoords[indices[n].t].y;
        }
    }else if (filename.endswith(".model"))
    {
        mesh_vertices.resize(readInt(stream));
        stream->read(mesh_vertices.data(), sizeof(MeshVertex) * mesh_vertices.size());
    }else{
        LOG(ERROR) << "Unknown mesh format: " << filename;
    }

    ret = new Mesh(std::move(mesh_vertices));
    meshMap[filename] = ret;
   
    return ret;
}
