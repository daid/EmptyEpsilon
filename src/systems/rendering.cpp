#include "systems/rendering.h"
#include "components/rendering.h"
#include "textureManager.h"
#include "vectorUtils.h"
#include "shaderRegistry.h"
#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>


std::vector<RenderSystem::RenderHandler> RenderSystem::render_handlers;

void RenderSystem::render3D(float aspect, float camera_fov)
{
    view_vector = vec2FromAngle(camera_yaw);
    depth_cutoff_back = camera_position.z * -tanf(glm::radians(90+camera_pitch + camera_fov/2.f));
    depth_cutoff_front = camera_position.z * -tanf(glm::radians(90+camera_pitch - camera_fov/2.f));
    if (camera_pitch - camera_fov/2.f <= 0.f)
        depth_cutoff_front = std::numeric_limits<float>::infinity();
    if (camera_pitch + camera_fov/2.f >= 180.f)
        depth_cutoff_back = -std::numeric_limits<float>::infinity();
    for(auto& handler : render_handlers)
        (this->*(handler.func))(handler.rif, handler.transparent);
    
    for(int n=render_lists.size() - 1; n >= 0; n--)
    {
        auto& render_list = render_lists[n];
        std::sort(render_list.begin(), render_list.end(), [](const RenderEntry& a, const RenderEntry& b) { return a.depth > b.depth; });

        auto projection = glm::perspective(glm::radians(camera_fov), aspect, 1.f, 25000.f * (n + 1));
        // Update projection matrix in shaders.
        ShaderRegistry::updateProjectionView(projection, {});

        glDepthMask(true);

        glDisable(GL_BLEND);
        for(auto info : render_list)
            if (!info.transparent)
                info.rif->render3D(info.entity);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        glDepthMask(false);
        for(auto info : render_list)
            if (info.transparent)
                info.rif->render3D(info.entity);
    }
}

MeshRenderSystem::MeshRenderSystem()
{
    RenderSystem::add3DHandler<MeshRenderComponent>(this, false);
}

void MeshRenderSystem::update(float delta)
{
}

void MeshRenderSystem::render3D(sp::ecs::Entity e)
{
    auto mrc = e.getComponent<MeshRenderComponent>();
    if (!mrc) return;
    auto transform = e.getComponent<sp::Transform>();
    if (!transform) return;

    if (!mrc->mesh.ptr && !mrc->mesh.name.empty())
        mrc->mesh.ptr = Mesh::getMesh(mrc->mesh.name);
    if (!mrc->mesh.ptr)
        return;
    if (!mrc->texture.ptr && !mrc->texture.name.empty())
        mrc->texture.ptr = textureManager.getTexture(mrc->texture.name);
    if (!mrc->specular_texture.ptr && !mrc->specular_texture.name.empty())
        mrc->specular_texture.ptr = textureManager.getTexture(mrc->specular_texture.name);
    if (!mrc->illumination_texture.ptr && !mrc->illumination_texture.name.empty())
        mrc->illumination_texture.ptr = textureManager.getTexture(mrc->illumination_texture.name);

    auto position = transform->getPosition();
    auto rotation = transform->getRotation();
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, 0.f });
    model_matrix = glm::rotate(model_matrix, glm::radians(rotation), glm::vec3{ 0.f, 0.f, 1.f });
    model_matrix = glm::translate(model_matrix, mrc->mesh_offset);

    // EE's coordinate flips to a Z-up left hand.
    // To account for that, flip the model around 180deg.
    auto modeldata_matrix = glm::rotate(model_matrix, glm::radians(180.f), {0.f, 0.f, 1.f});
    modeldata_matrix = glm::scale(modeldata_matrix, glm::vec3{mrc->scale});
    //modeldata_matrix = glm::translate(modeldata_matrix, mrc->mesh_offset); // Old mesh offset

    auto shader_id = ShaderRegistry::Shaders::Object;
    if (mrc->texture.ptr && mrc->specular_texture.ptr && mrc->illumination_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectSpecularIllumination;
    else if (mrc->texture.ptr && mrc->specular_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectSpecular;
    else if (mrc->texture.ptr && mrc->illumination_texture.ptr)
        shader_id = ShaderRegistry::Shaders::ObjectIllumination;

    ShaderRegistry::ScopedShader shader(shader_id);
    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(modeldata_matrix));

    // Lights setup.
    ShaderRegistry::setupLights(shader.get(), model_matrix);

    // Textures
    if (mrc->texture.ptr)
        mrc->texture.ptr->bind();

    if (mrc->specular_texture.ptr)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
        mrc->specular_texture.ptr->bind();
    }

    if (mrc->illumination_texture.ptr)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::IlluminationMap));
        mrc->illumination_texture.ptr->bind();
    }

    // Draw
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

    mrc->mesh.ptr->render(positions.get(), texcoords.get(), normals.get());

    if (mrc->specular_texture.ptr || mrc->illumination_texture.ptr)
        glActiveTexture(GL_TEXTURE0);
}

BeamRenderSystem::BeamRenderSystem()
{
    RenderSystem::add3DHandler<BeamRenderer>(this, false);
}

void BeamRenderSystem::update(float delta)
{
}

void BeamRenderSystem::render3D(sp::ecs::Entity e)
{
    auto br = e.getComponent<BeamRenderer>();
    if (!br) return;
    auto transform = e.getComponent<sp::Transform>();
    if (!transform) return;

    
    glm::vec3 startPoint(transform->getPosition().x, transform->getPosition().y, br->source_offset.z);
    glm::vec3 endPoint(br->target_location.x, br->target_location.y, br->target_offset.z);
    glm::vec3 eyeNormal = glm::normalize(glm::cross(camera_position - startPoint, endPoint - startPoint));

    if (!br->texture.ptr && !br->texture.name.empty())
        br->texture.ptr = textureManager.getTexture(br->texture.name);
    if (br->texture.ptr)
        br->texture.ptr->bind();

    ShaderRegistry::ScopedShader beamShader(ShaderRegistry::Shaders::Basic);

    glUniform4f(beamShader.get().uniform(ShaderRegistry::Uniforms::Color), br->lifetime, br->lifetime, br->lifetime, 1.f);
    glUniformMatrix4fv(beamShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(getModelMatrix()));
    
    gl::ScopedVertexAttribArray positions(beamShader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(beamShader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    std::array<VertexAndTexCoords, 4> quad;
    // Beam
    {
        glm::vec3 v0 = startPoint + eyeNormal * 4.0f;
        glm::vec3 v1 = endPoint + eyeNormal * 4.0f;
        glm::vec3 v2 = endPoint - eyeNormal * 4.0f;
        glm::vec3 v3 = startPoint - eyeNormal * 4.0f;
        quad[0].vertex = v0;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v1;
        quad[1].texcoords = { 0.f, 1.f };
        quad[2].vertex = v2;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v3;
        quad[3].texcoords = { 1.f, 0.f };

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        // Draw the beam
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

NebulaRenderSystem::NebulaRenderSystem()
{
    RenderSystem::add3DHandler<NebulaRenderSystem>(this, true);
}

void NebulaRenderSystem::update(float delta)
{
}

void NebulaRenderSystem::render3D(sp::ecs::Entity e)
{
    auto nr = e.getComponent<NebulaRenderer>();
    if (!nr) return;
    auto transform = e.getComponent<sp::Transform>();
    if (!transform) return;

    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    struct VertexAndTexCoords
    {
        glm::vec3 vertex;
        glm::vec2 texcoords;
    };
    std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    for(auto& cloud : nr->clouds)
    {
        glm::vec3 position = glm::vec3(transform->getPosition().x, transform->getPosition().y, 0) + glm::vec3(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;

        float distance = glm::length(camera_position - position);
        float alpha = 1.0f - (distance / 10000.0f);
        if (alpha < 0.0f)
            continue;

        // setup our quad.
        for (auto& point : quad)
        {
            point.vertex = position;
        }

        if (!cloud.texture.ptr)
            cloud.texture.ptr = textureManager.getTexture(cloud.texture.name);
        if (cloud.texture.ptr)
            cloud.texture.ptr->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        auto cloud_model_matrix = glm::translate(glm::identity<glm::mat4>(), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(cloud_model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 3, 2, 0, 2, 1 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}
