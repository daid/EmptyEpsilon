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
