#include "planet.h"
#include "components/rendering.h"
#include "engine.h"
#include "textureManager.h"
#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>


static Mesh* planet_mesh[16];

class PlanetMeshGenerator
{
public:
    std::vector<MeshVertex> vertices;
    int max_iterations;

    PlanetMeshGenerator(int iterations)
    {
        max_iterations = iterations;

        createFace(0, glm::vec3(0, 0, 1), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0), glm::vec2(0, 1), glm::vec2(0, 0.5), glm::vec2(0.25, 0.5));
        createFace(0, glm::vec3(0, 0, 1), glm::vec3(1, 0, 0), glm::vec3(0,-1, 0), glm::vec2(0.25, 1), glm::vec2(0.25, 0.5), glm::vec2(0.5, 0.5));
        createFace(0, glm::vec3(0, 0, 1), glm::vec3(0,-1, 0), glm::vec3(-1, 0, 0), glm::vec2(0.5, 1), glm::vec2(0.5, 0.5), glm::vec2(0.75, 0.5));
        createFace(0, glm::vec3(0, 0, 1), glm::vec3(-1, 0, 0), glm::vec3(0, 1, 0), glm::vec2(0.75, 1), glm::vec2(0.75, 0.5), glm::vec2(1.0, 0.5));

        createFace(0, glm::vec3(0, 0,-1), glm::vec3(1, 0, 0), glm::vec3(0, 1, 0), glm::vec2(0, 0), glm::vec2(0.25, 0.5), glm::vec2(0.0, 0.5));
        createFace(0, glm::vec3(0, 0,-1), glm::vec3(0,-1, 0), glm::vec3(1, 0, 0), glm::vec2(0.25, 0), glm::vec2(0.5, 0.5), glm::vec2(0.25, 0.5));
        createFace(0, glm::vec3(0, 0,-1), glm::vec3(-1, 0, 0), glm::vec3(0,-1, 0), glm::vec2(0.5, 0), glm::vec2(0.75, 0.5), glm::vec2(0.5, 0.5));
        createFace(0, glm::vec3(0, 0,-1), glm::vec3(0,1, 0), glm::vec3(-1, 0, 0), glm::vec2(0.75, 0), glm::vec2(1.0, 0.5), glm::vec2(0.75, 0.5));

        for(unsigned int n=0; n<vertices.size(); n++)
        {
            float u = vec2ToAngle(glm::vec2(vertices[n].position[1], vertices[n].position[0])) / 360.0f;
            if (u < 0.0f)
                u = 1.0f + u;
            if (std::abs(u - vertices[n].uv[0]) > 0.5f)
                u += 1.0f;
            vertices[n].uv[0] = u;
            vertices[n].uv[1] = 0.5f + vec2ToAngle(glm::vec2(glm::length(glm::vec2(vertices[n].position[0], vertices[n].position[1])), -vertices[n].position[2])) / 180.0f;
        }
    }

    void createFace(int iteration, glm::vec3 v0, glm::vec3 v1, glm::vec3 v2, glm::vec2 uv0, glm::vec2 uv1, glm::vec2 uv2)
    {
        if (iteration < max_iterations)
        {
            glm::vec3 v01 = v0 + v1;
            glm::vec3 v12 = v1 + v2;
            glm::vec3 v02 = v0 + v2;
            glm::vec2 uv01 = (uv0 + uv1) / 2.0f;
            glm::vec2 uv12 = (uv1 + uv2) / 2.0f;
            glm::vec2 uv02 = (uv0 + uv2) / 2.0f;
            v01 /= glm::length(v01);
            v12 /= glm::length(v12);
            v02 /= glm::length(v02);
            createFace(iteration + 1, v0, v01, v02, uv0, uv01, uv02);
            createFace(iteration + 1, v01, v1, v12, uv01, uv1, uv12);
            createFace(iteration + 1, v01, v12, v02, uv01, uv12, uv02);
            createFace(iteration + 1, v2, v02, v12, uv2, uv02, uv12);
        }else{
            vertices.emplace_back();
            vertices.back().position[0] = v0.x;
            vertices.back().position[1] = v0.y;
            vertices.back().position[2] = v0.z;
            vertices.back().normal[0] = v0.x;
            vertices.back().normal[1] = v0.y;
            vertices.back().normal[2] = v0.z;
            vertices.back().uv[0] = uv0.x;
            vertices.back().uv[1] = uv0.y;

            vertices.emplace_back();
            vertices.back().position[0] = v1.x;
            vertices.back().position[1] = v1.y;
            vertices.back().position[2] = v1.z;
            vertices.back().normal[0] = v1.x;
            vertices.back().normal[1] = v1.y;
            vertices.back().normal[2] = v1.z;
            vertices.back().uv[0] = uv1.x;
            vertices.back().uv[1] = uv1.y;

            vertices.emplace_back();
            vertices.back().position[0] = v2.x;
            vertices.back().position[1] = v2.y;
            vertices.back().position[2] = v2.z;
            vertices.back().normal[0] = v2.x;
            vertices.back().normal[1] = v2.y;
            vertices.back().normal[2] = v2.z;
            vertices.back().uv[0] = uv2.x;
            vertices.back().uv[1] = uv2.y;
        }
    }
};

void PlanetRenderSystem::update(float delta)
{
}

void PlanetRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr)
{
    float distance = glm::length(camera_position - glm::vec3(transform.getPosition().x, transform.getPosition().y, pr.distance_from_movement_plane));

    //view_scale ~= about the size the planet is on the screen.
    float view_scale = pr.size / distance;
    int level_of_detail = 4;
    if (view_scale < 0.01f)
        level_of_detail = 2;
    if (view_scale < 0.1f)
        level_of_detail = 3;

    if (pr.texture != "" && pr.size > 0)
    {
        if (!planet_mesh[level_of_detail])
        {
            PlanetMeshGenerator planet_mesh_generator(level_of_detail);
            planet_mesh[level_of_detail] = new Mesh(std::move(planet_mesh_generator.vertices));
        }

        auto position = transform.getPosition();
        auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, pr.distance_from_movement_plane });
        model_matrix = glm::rotate(model_matrix, glm::radians(transform.getRotation()), glm::vec3{ 0.f, 0.f, 1.f });

        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Planet);
        auto planet_matrix = glm::scale(model_matrix, glm::vec3(pr.size));
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(planet_matrix));
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 1.f);
        glUniform4fv(shader.get().uniform(ShaderRegistry::Uniforms::AtmosphereColor), 1, glm::value_ptr(glm::vec4(pr.atmosphere_color, 1.f)));

        ShaderRegistry::setupLights(shader.get(), planet_matrix);

        textureManager.getTexture(pr.texture)->bind();
        {
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
            gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
            gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

            planet_mesh[level_of_detail]->render(positions.get(), texcoords.get(), normals.get());
        }
    }
}

void PlanetRenderSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, PlanetRender& component)
{
    auto physics = e.getComponent<sp::Physics>();
    if (physics)
    {
        renderer.fillCircle(screen_position, physics->getSize().x * scale, glm::u8vec4(component.atmosphere_color * 255.f, 128));
    }
}

void PlanetTransparentRenderSystem::update(float delta)
{
}

void PlanetTransparentRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr)
{
    float distance = glm::length(camera_position - glm::vec3(transform.getPosition().x, transform.getPosition().y, pr.distance_from_movement_plane));

    //view_scale ~= about the size the planet is on the screen.
    float view_scale = pr.size / distance;
    int level_of_detail = 4;
    if (view_scale < 0.01f)
        level_of_detail = 2;
    if (view_scale < 0.1f)
        level_of_detail = 3;

    auto position = transform.getPosition();
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, pr.distance_from_movement_plane });
    model_matrix = glm::rotate(model_matrix, glm::radians(transform.getRotation()), glm::vec3{ 0.f, 0.f, 1.f });

    if (pr.cloud_texture != "" && pr.cloud_size > 0)
    {
       
        if (!planet_mesh[level_of_detail])
        {
            PlanetMeshGenerator planet_mesh_generator(level_of_detail);
            planet_mesh[level_of_detail] = new Mesh(std::move(planet_mesh_generator.vertices));
        }

        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Planet);
        auto cloud_matrix = glm::scale(model_matrix, glm::vec3(pr.cloud_size));
        cloud_matrix = glm::rotate(cloud_matrix, glm::radians(engine->getElapsedTime() * 1.0f), glm::vec3(0.f, 0.f, 1.f));

        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(cloud_matrix));
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.f, 1.f, 1.f, 1.f);
        glUniform4fv(shader.get().uniform(ShaderRegistry::Uniforms::AtmosphereColor), 1, glm::value_ptr(glm::vec4(0.f)));

        ShaderRegistry::setupLights(shader.get(), cloud_matrix);

        textureManager.getTexture(pr.cloud_texture)->bind();
        {
            gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
            gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
            gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

            planet_mesh[level_of_detail]->render(positions.get(), texcoords.get(), normals.get());
        }
    }
    if (pr.atmosphere_texture != "" && pr.atmosphere_size > 0)
    {
        struct VertexAndTexCoords
        {
            glm::vec3 vertex;
            glm::vec2 texcoords;
        };
        static std::array<VertexAndTexCoords, 4> quad{
            glm::vec3(), {0.f, 1.f},
            glm::vec3(), {1.f, 1.f},
            glm::vec3(), {1.f, 0.f},
            glm::vec3(), {0.f, 0.f}
        };

        ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

        textureManager.getTexture(pr.atmosphere_texture)->bind();
        glm::vec4 color(pr.atmosphere_color, pr.atmosphere_size * 2.0f);
        glUniform4fv(shader.get().uniform(ShaderRegistry::Uniforms::Color), 1, glm::value_ptr(color));
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        
        gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));

        std::initializer_list<uint16_t> indices = { 0, 2, 1, 0, 3, 2 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}
