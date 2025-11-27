#include <graphics/opengl.h>
#include <unordered_map>
#include <SDL_endian.h>
#include <meshoptimizer.h>
#include <glm/gtx/norm.hpp>

#include "resources.h"
#include "random.h"
#include "mesh.h"


struct ModelDataVertex
{
    float position[3];
    float normal[3];
    float uv[2];
};


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

Mesh::Mesh(std::vector<MeshVertex>&& unindexed_vertices)
    :face_count{ static_cast<uint32_t>(unindexed_vertices.size()) / 3}
{
    if (!unindexed_vertices.empty())
    {
        vbo_ibo = gl::Buffers<2>{};

        auto index_count = 3 * face_count;
        std::vector<uint32_t> remap_indices;
        {
            std::vector<uint32_t> remap(index_count); // allocate temporary memory for the remap table
            vertices.resize(meshopt_generateVertexRemap(remap.data(), nullptr, index_count, unindexed_vertices.data(), index_count, sizeof(MeshVertex)));

            remap_indices.resize(index_count * sizeof(uint32_t));
            meshopt_remapIndexBuffer(reinterpret_cast<uint32_t*>(remap_indices.data()), nullptr, index_count, remap.data());
            meshopt_remapVertexBuffer(vertices.data(), unindexed_vertices.data(), index_count, sizeof(MeshVertex), remap.data());

            if (vertices.size() > size_t{ std::numeric_limits<uint16_t>::max() })
            {
                // ES 2 only supports u16 for indices - u32 is only available through an extension
                // (a lot of systems should have it, but SP doesn't have support for it yet).
                // Forego the indices, and inform the user.
                vertices = std::move(unindexed_vertices);
                LOG(WARNING) << "Loading mesh with a large number of vertices (" << vertices.size() << ").";
            }
            else
            {
                indices.assign(std::begin(remap_indices), std::end(remap_indices));
                unindexed_vertices.clear();
            }
        }

        glBindBuffer(GL_ARRAY_BUFFER, vbo_ibo[0]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(MeshVertex) * vertices.size(), vertices.data(), GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);

        if (!indices.empty())
        {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_ibo[1]);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_count * sizeof(uint16_t), indices.data(), GL_STATIC_DRAW);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
        }

        greatest_distance_from_center = greatestDistanceFromCenter(vertices);
    }
}

void Mesh::render(int32_t position_attrib, int32_t texcoords_attrib, int32_t normal_attrib, int32_t tangent_attrib)
{
    if (vertices.empty() || vbo_ibo[0] == NO_BUFFER || (!indices.empty() && vbo_ibo[1] == NO_BUFFER))
        return;

    glBindBuffer(GL_ARRAY_BUFFER, vbo_ibo[0]);

    if (position_attrib != -1)
        glVertexAttribPointer(position_attrib, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, position));

    if (normal_attrib != -1)
        glVertexAttribPointer(normal_attrib, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, normal));

    if (texcoords_attrib != -1)
        glVertexAttribPointer(texcoords_attrib, 2, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, uv));

    if (tangent_attrib != -1)
        glVertexAttribPointer(tangent_attrib, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (void*)offsetof(MeshVertex, tangent));

    if (!indices.empty())
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_ibo[1]);
        glDrawElements(GL_TRIANGLES, face_count * 3, GL_UNSIGNED_SHORT, nullptr);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_NONE);
    }

    else
    {
        glDrawArrays(GL_TRIANGLES, 0, static_cast<GLsizei>(vertices.size()));
    }

    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);
}

glm::vec3 Mesh::randomPoint()
{
    if (vertices.empty())
        return glm::vec3{};

    // Pick a face
    size_t v0_index{}, v1_index{}, v2_index{};
    if (!indices.empty())
    {
        auto face_index = static_cast<size_t>(irandom(0, face_count - 1));
        v0_index = indices[3 * face_index];
        v1_index = indices[3 * face_index + 1];
        v2_index = indices[3 * face_index + 2];
    }
    else
    {

        v0_index = static_cast<size_t>(irandom(0, static_cast<int>(vertices.size()) / 3 - 1)) * 3;
        v1_index = v0_index + 1;
        v2_index = v0_index + 2;
    }

    glm::vec3 v0(vertices[v0_index].position[0], vertices[v0_index].position[1], vertices[v0_index].position[2]);
    glm::vec3 v1(vertices[v1_index].position[0], vertices[v1_index].position[1], vertices[v1_index].position[2]);
    glm::vec3 v2(vertices[v2_index].position[0], vertices[v2_index].position[1], vertices[v2_index].position[2]);

    float f1 = random(0.f, 1.f);
    float f2 = random(0.f, 1.f);
    if (f1 + f2 > 1.0f)
    {
        f1 = 1.0f - f1;
        f2 = 1.0f - f2;
    }
    glm::vec3 v01 = (v0 * f1) + (v1 * (1.0f - f1));
    glm::vec3 ret = (v01 * f2) + (v2 * (1.0f - f2));
    return ret;
}

float Mesh::greatestDistanceFromCenter(std::vector<MeshVertex>& vertices)
{
    if (vertices.empty()) {
        return 0;
    }

    glm::vec3 sum{};
    for(auto vertex : vertices) sum += glm::vec3{vertex.position[0], vertex.position[1], vertex.position[2]};
    auto average = sum / float(vertices.size());

    auto greatest_distance = 0.f;
    for(auto vertex : vertices)
    {
        float distance = glm::distance(average, glm::vec3{vertex.position[0], vertex.position[1], vertex.position[2]});
        if(distance > greatest_distance) {
            greatest_distance = distance;
        }
    }
    return greatest_distance;
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
        bool parsing_ok = true;
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
                    if (parts.size() >= 4)
                    {
                        vertices.emplace_back(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat());
                    }
                    else
                    {
                        LOG(ERROR, "Bad vertex line: ", line);
                        parsing_ok = false;
                    }

                }else if (parts[0] == "vn")
                {
                    if (parts.size() >= 4)
                    {
                        normals.push_back(glm::normalize(glm::vec3(parts[1].toFloat(), parts[2].toFloat(), parts[3].toFloat())));
                    }
                    else
                    {
                        LOG(ERROR, "Bad normal line: ", line);
                        parsing_ok = false;
                    }

                }else if (parts[0] == "vt")
                {
                    if (parts.size() >= 3)
                    {
                        texCoords.push_back(glm::vec2(parts[1].toFloat(), parts[2].toFloat()));
                    }
                    else
                    {
                        LOG(ERROR, "Bad vertex texcoord line: ", line);
                        parsing_ok = false;
                    }

                }else if (parts[0] == "f")
                {
                    if (parts.size() >= 4)
                    {
                        for (unsigned int n = 3; parsing_ok && n < parts.size(); n++)
                        {
                            std::vector<string> p0 = parts[1].split("/");
                            std::vector<string> p1 = parts[n].split("/");
                            std::vector<string> p2 = parts[n - 1].split("/");

                            if (p0.size() == 3 && p1.size() == 3 && p2.size() == 3)
                            {
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
                            else
                            {
                                LOG(ERROR, "Bad face triangle: ", line);
                                parsing_ok = false;
                            }
                        }
                    }
                    else
                    {
                        LOG(ERROR, "Bad face line: ", line);
                        parsing_ok = false;
                    }
                }else{
                    LOG(DEBUG, "mesh: ignored: ", line);
                }
            }
        }while(parsing_ok && stream->tell() < stream->getSize());

        if (parsing_ok)
        {
            mesh_vertices.resize(indices.size());
            for (unsigned int n = 0; n < indices.size(); n++)
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
        }
        else
        {
            LOG(ERROR, "Failed to parse ", filename);
        }


    }else if (filename.endswith(".model"))
    {
        std::vector<ModelDataVertex> model_data_vertices;
        model_data_vertices.resize(readInt(stream));
        stream->read(model_data_vertices.data(), sizeof(ModelDataVertex) * model_data_vertices.size());
        mesh_vertices.resize(model_data_vertices.size());
        for(auto idx=0U; idx<model_data_vertices.size(); idx++) {
            mesh_vertices[idx].position[0] = model_data_vertices[idx].position[0];
            mesh_vertices[idx].position[1] = model_data_vertices[idx].position[1];
            mesh_vertices[idx].position[2] = model_data_vertices[idx].position[2];
            mesh_vertices[idx].normal[0] = model_data_vertices[idx].normal[0];
            mesh_vertices[idx].normal[1] = model_data_vertices[idx].normal[1];
            mesh_vertices[idx].normal[2] = model_data_vertices[idx].normal[2];
            mesh_vertices[idx].uv[0] = model_data_vertices[idx].uv[0];
            mesh_vertices[idx].uv[1] = model_data_vertices[idx].uv[1];
        }
    }else{
        LOG(ERROR) << "Unknown mesh format: " << filename;
    }

    if (!mesh_vertices.empty())
    {
        // Calculate tangent
        for(auto idx=0U; idx<mesh_vertices.size(); idx+=3) {
            auto p0 = glm::vec3(mesh_vertices[idx+0].position[0], mesh_vertices[idx+0].position[1], mesh_vertices[idx+0].position[2]);
            auto p1 = glm::vec3(mesh_vertices[idx+1].position[0], mesh_vertices[idx+1].position[1], mesh_vertices[idx+1].position[2]);
            auto p2 = glm::vec3(mesh_vertices[idx+2].position[0], mesh_vertices[idx+2].position[1], mesh_vertices[idx+2].position[2]);
            auto uv0 = glm::vec2(mesh_vertices[idx+0].uv[0], mesh_vertices[idx+0].uv[1]);
            auto uv1 = glm::vec2(mesh_vertices[idx+1].uv[0], mesh_vertices[idx+1].uv[1]);
            auto uv2 = glm::vec2(mesh_vertices[idx+2].uv[0], mesh_vertices[idx+2].uv[1]);

            glm::vec3 edge1 = p1 - p0;
            glm::vec3 edge2 = p2 - p0;
            glm::vec2 deltaUV1 = uv1 - uv0;
            glm::vec2 deltaUV2 = uv2 - uv0;

            float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);

            auto tangent = glm::vec3(
                    f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x),
                    f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y),
                    f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z));

            for(int n=0; n<3; n++) {
                mesh_vertices[idx+n].tangent[0] = tangent.x;
                mesh_vertices[idx+n].tangent[1] = tangent.y;
                mesh_vertices[idx+n].tangent[2] = tangent.z;
            }
        }


        ret = new Mesh(std::move(mesh_vertices));
        meshMap[filename] = ret;
    }


    return ret;
}
