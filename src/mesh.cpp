#include <GL/glew.h>
#include <unordered_map>
#include "engine.h"
#include "mesh.h"

static inline int readInt(P<ResourceStream> stream)
{
    int32_t ret = 0;
    stream->read(&ret, sizeof(int32_t));
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ || defined(_WIN32)
    return (ret & 0xFF) << 24 | (ret & 0xFF00) << 8 | (ret & 0xFF0000) >> 8 | (ret & 0xFF000000) >> 24;
#endif
    return ret;
}

const unsigned int NO_BUFFER = 0;

static std::unordered_map<string, Mesh*> meshMap;

Mesh::Mesh()
{
    vertices = NULL;
    indices = NULL;
    vertexCount = 0;
    vbo = NO_BUFFER;
}

Mesh::~Mesh()
{
    if (vertices) delete vertices;
    if (indices) delete indices;
    if (vbo != NO_BUFFER)
        glDeleteBuffers(1, &vbo);
}

void Mesh::render()
{
    if (glGenBuffers)
    {
        if (vbo == NO_BUFFER)
        {
            glGenBuffers(1, &vbo);
            glBindBuffer(GL_ARRAY_BUFFER, vbo);
            glBufferData(GL_ARRAY_BUFFER, sizeof(MeshVertex) * vertexCount, &vertices[0], GL_STATIC_DRAW);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        }
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
        glVertexPointer(3, GL_FLOAT, sizeof(float) * (3 * 2 + 2), (void*)offsetof(MeshVertex, position));
        glNormalPointer(GL_FLOAT, sizeof(float) * (3 * 2 + 2), (void*)offsetof(MeshVertex, normal));
        glTexCoordPointer(2, GL_FLOAT, sizeof(float) * (3 * 2 + 2), (void*)offsetof(MeshVertex, uv));
        glDrawArrays(GL_TRIANGLES, 0, vertexCount);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }else{
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
        glVertexPointer(3, GL_FLOAT, sizeof(float) * (3 * 2 + 2), &vertices[0].position[0]);
        glNormalPointer(GL_FLOAT, sizeof(float) * (3 * 2 + 2), &vertices[0].normal[0]);
        glTexCoordPointer(2, GL_FLOAT, sizeof(float) * (3 * 2 + 2), &vertices[0].uv[0]);
        glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    }
}

sf::Vector3f Mesh::randomPoint()
{
    //int idx = irandom(0, vertexCount-1);
    //return sf::Vector3f(vertices[idx].position[0], vertices[idx].position[1], vertices[idx].position[2]);
    int idx = irandom(0, vertexCount / 3) * 3;
    sf::Vector3f v0 = sf::Vector3f(vertices[idx].position[0], vertices[idx].position[1], vertices[idx].position[2]);
    sf::Vector3f v1 = sf::Vector3f(vertices[idx+1].position[0], vertices[idx+1].position[1], vertices[idx+1].position[2]);
    sf::Vector3f v2 = sf::Vector3f(vertices[idx+2].position[0], vertices[idx+2].position[1], vertices[idx+2].position[2]);
    
    float f1 = random(0.0, 1.0);
    float f2 = random(0.0, 1.0);
    if (f1 + f2 > 1.0f)
    {
        f1 = 1.0f - f1;
        f2 = 1.0f - f2;
    }
    sf::Vector3f v01 = (v0 * f1) + (v1 * (1.0f - f1));
    sf::Vector3f ret = (v01 * f2) + (v2 * (1.0f - f2));
    return ret;
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

    ret = new Mesh();
    if (filename.endswith(".obj"))
    {
        std::vector<sf::Vector3f> vertices;
        std::vector<sf::Vector3f> normals;
        std::vector<sf::Vector2f> texCoords;
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
            ret->vertices[n].position[0] = -vertices[indices[n].v].x;
            ret->vertices[n].position[1] = vertices[indices[n].v].z;
            ret->vertices[n].position[2] = vertices[indices[n].v].y;
            ret->vertices[n].normal[0] = -normals[indices[n].n].x;
            ret->vertices[n].normal[1] = normals[indices[n].n].z;
            ret->vertices[n].normal[2] = normals[indices[n].n].y;
            ret->vertices[n].uv[0] = texCoords[indices[n].t].x;
            ret->vertices[n].uv[1] = 1.0 - texCoords[indices[n].t].y;
        }
    }else if (filename.endswith(".model"))
    {
        ret->vertexCount = readInt(stream);
        ret->vertices = new MeshVertex[ret->vertexCount];
        stream->read(ret->vertices, sizeof(MeshVertex) * ret->vertexCount);
    }else{
        LOG(ERROR) << "Unknown mesh format: " << filename;
    }

    meshMap[filename] = ret;
    return ret;
}
