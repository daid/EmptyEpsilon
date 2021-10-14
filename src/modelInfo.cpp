#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>

#include "particleEffect.h"
#include "modelInfo.h"
#include "featureDefs.h"
#include "main.h"

#include "shaderRegistry.h"

ModelInfo::ModelInfo()
: last_engine_particle_time(0), last_warp_particle_time(0), engine_scale(0), warp_scale(0.0f)
{
}

void ModelInfo::setData(string name)
{
    this->data = ModelData::getModel(name);
    if (!this->data)
    {
        LOG(WARNING) << "Failed to find model data for: " << name;
    }
}

void ModelInfo::render(glm::vec2 position, float rotation, const glm::mat4& model_view)
{
    if (!data)
        return;

    data->render(model_view);

    if (engine_scale > 0.0f)
    {
        if (engine->getElapsedTime() - last_engine_particle_time > 0.1f)
        {
            for (unsigned int n=0; n<data->engine_emitters.size(); n++)
            {
                glm::vec3 offset = data->engine_emitters[n].position * data->scale;
                glm::vec2 pos2d = position + rotateVec2(glm::vec2(offset.x, offset.y), rotation);
                glm::vec3 color = data->engine_emitters[n].color;
                glm::vec3 pos3d = glm::vec3(pos2d.x, pos2d.y, offset.z);
                float scale = data->scale * data->engine_emitters[n].scale * engine_scale;
                ParticleEngine::spawn(pos3d, pos3d, color, color, scale, 0.0, 5.0);
            }
            last_engine_particle_time = engine->getElapsedTime();
        }
    }

    if (warp_scale > 0.0f)
    {
        if (engine->getElapsedTime() - last_warp_particle_time > 0.1f)
        {
            int count = warp_scale * 10.0f;
            for(int n=0; n<count; n++)
            {
                glm::vec3 offset = (data->mesh->randomPoint() + data->mesh_offset) * data->scale;
                glm::vec2 pos2d = position + rotateVec2(glm::vec2(offset.x, offset.y), rotation);
                glm::vec3 color = glm::vec3(0.6, 0.6, 1);
                glm::vec3 pos3d = glm::vec3(pos2d.x, pos2d.y, offset.z);
                ParticleEngine::spawn(pos3d, pos3d, color, color, data->getRadius() / 15.0f, 0.0, 3.0);
            }
            last_warp_particle_time = engine->getElapsedTime();
        }
    }
}

void ModelInfo::renderOverlay(const glm::mat4& model_view, sp::Texture* texture, float alpha)
{
    if (!data)
        return;

    auto model_matrix = glm::mat4(1.0f);
    model_matrix = glm::rotate(model_matrix, 180.f / 180.0f * float(M_PI), {0.f, 0.f, 1.f});
    model_matrix = glm::scale(model_matrix, {data->scale, data->scale, data->scale});
    model_matrix = glm::translate(model_matrix, data->mesh_offset);

    glDepthFunc(GL_EQUAL);
    {
        ShaderRegistry::ScopedShader basicShader(ShaderRegistry::Shaders::Basic);

        glUniform4f(basicShader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::View), 1, GL_FALSE, glm::value_ptr(model_view));
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        texture->bind();

        gl::ScopedVertexAttribArray positions(basicShader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(basicShader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(basicShader.get().attribute(ShaderRegistry::Attributes::Normal));

        data->mesh->render(positions.get(), texcoords.get(), normals.get());
    }
    
    glDepthFunc(GL_LESS);
}

void ModelInfo::renderShield(const glm::mat4& model_view, float alpha)
{
    auto model_matrix = glm::mat4(1.0f);
    model_matrix = glm::rotate(model_matrix, engine->getElapsedTime() * 5 / 180.0f * float(M_PI), {0.f, 0.f, 1.f});
    model_matrix = glm::scale(model_matrix, {data->radius * 1.2f, data->radius * 1.2f, data->radius * 1.2f});

    Mesh* m = Mesh::getMesh("mesh/sphere.obj");
    {
        ShaderRegistry::ScopedShader basicShader(ShaderRegistry::Shaders::Basic);

        glUniform4f(basicShader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::View), 1, GL_FALSE, glm::value_ptr(model_view));
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        textureManager.getTexture("texture/shield_hit_effect.png")->bind();

        gl::ScopedVertexAttribArray positions(basicShader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(basicShader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(basicShader.get().attribute(ShaderRegistry::Attributes::Normal));

        m->render(positions.get(), texcoords.get(), normals.get());
    }
}

void ModelInfo::renderShield(const glm::mat4& model_view, float alpha, float angle)
{
    if (!data)
        return;
    auto model_matrix = glm::mat4(1.0f);
    model_matrix = glm::rotate(model_matrix, angle / 180.0f * float(M_PI), {0.f, 0.f, 1.f});
    model_matrix = glm::rotate(model_matrix, engine->getElapsedTime() * 5 / 180.0f * float(M_PI), {1.f, 0.f, 0.f});
    model_matrix = glm::scale(model_matrix, {data->radius * 1.2f, data->radius * 1.2f, data->radius * 1.2f});
    Mesh* m = Mesh::getMesh("mesh/half_sphere.obj");
    {
        ShaderRegistry::ScopedShader basicShader(ShaderRegistry::Shaders::Basic);

        glUniform4f(basicShader.get().uniform(ShaderRegistry::Uniforms::Color), alpha, alpha, alpha, 1.f);
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::View), 1, GL_FALSE, glm::value_ptr(model_view));
        glUniformMatrix4fv(basicShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
        textureManager.getTexture("texture/shield_hit_effect.png")->bind();

        gl::ScopedVertexAttribArray positions(basicShader.get().attribute(ShaderRegistry::Attributes::Position));
        gl::ScopedVertexAttribArray texcoords(basicShader.get().attribute(ShaderRegistry::Attributes::Texcoords));
        gl::ScopedVertexAttribArray normals(basicShader.get().attribute(ShaderRegistry::Attributes::Normal));

        m->render(positions.get(), texcoords.get(), normals.get());
    }
}
