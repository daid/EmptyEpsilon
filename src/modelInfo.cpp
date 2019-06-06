#include <SFML/OpenGL.hpp>

#include "particleEffect.h"
#include "modelInfo.h"
#include "featureDefs.h"
#include "main.h"

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

void ModelInfo::render(sf::Vector2f position, float rotation)
{
    if (!data)
        return;

    data->render();

    if (engine_scale > 0.0f)
    {
        if (engine->getElapsedTime() - last_engine_particle_time > 0.1)
        {
            for (unsigned int n=0; n<data->engine_emitters.size(); n++)
            {
                sf::Vector3f offset = data->engine_emitters[n].position * data->scale;
                sf::Vector2f pos2d = position + sf::rotateVector(sf::Vector2f(offset.x, offset.y), rotation);
                sf::Vector3f color = data->engine_emitters[n].color;
                sf::Vector3f pos3d = sf::Vector3f(pos2d.x, pos2d.y, offset.z);
                float scale = data->scale * data->engine_emitters[n].scale * engine_scale;
                ParticleEngine::spawn(pos3d, pos3d, color, color, scale, 0.0, 5.0);
            }
            last_engine_particle_time = engine->getElapsedTime();
        }
    }

    if (warp_scale > 0.0f)
    {
        if (engine->getElapsedTime() - last_warp_particle_time > 0.1)
        {
            int count = warp_scale * 10.0f;
            for(int n=0; n<count; n++)
            {
                sf::Vector3f offset = (data->mesh->randomPoint() + data->mesh_offset) * data->scale;
                sf::Vector2f pos2d = position + sf::rotateVector(sf::Vector2f(offset.x, offset.y), rotation);
                sf::Vector3f color = sf::Vector3f(0.6, 0.6, 1);
                sf::Vector3f pos3d = sf::Vector3f(pos2d.x, pos2d.y, offset.z);
                ParticleEngine::spawn(pos3d, pos3d, color, color, data->getRadius() / 15.0f, 0.0, 3.0);
            }
            last_warp_particle_time = engine->getElapsedTime();
        }
    }
}

void ModelInfo::renderOverlay(sf::Texture* texture, float alpha)
{
#if FEATURE_3D_RENDERING
    if (!data)
        return;

    glPushMatrix();

    glScalef(data->scale, data->scale, data->scale);
    glTranslatef(data->mesh_offset.x, data->mesh_offset.y, data->mesh_offset.z);
    glDepthFunc(GL_EQUAL);
    glColor4f(alpha, alpha, alpha, 1);
    ShaderManager::getShader("basicShader")->setUniform("textureMap", *texture);
    sf::Shader::bind(ShaderManager::getShader("basicShader"));
    data->mesh->render();
    glDepthFunc(GL_LESS);

    glPopMatrix();
#endif//FEATURE_3D_RENDERING
}

void ModelInfo::renderShield(float alpha)
{
#if FEATURE_3D_RENDERING
    ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture("shield_hit_effect.png"));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));

    glPushMatrix();
    glColor4f(alpha, alpha, alpha, 1);
    glRotatef(engine->getElapsedTime() * 5, 0, 0, 1);
    glScalef(data->radius * 1.2, data->radius * 1.2, data->radius * 1.2);
    Mesh* m = Mesh::getMesh("sphere.obj");
    m->render();
    glPopMatrix();
#endif//FEATURE_3D_RENDERING
}

void ModelInfo::renderShield(float alpha, float angle)
{
#if FEATURE_3D_RENDERING
    if (!data) return;

    ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture("shield_hit_effect.png"));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));

    glPushMatrix();
    glColor4f(alpha, alpha, alpha, 1);
    glRotatef(angle, 0, 0, 1);
    glRotatef(engine->getElapsedTime() * 5, 1, 0, 0);
    glScalef(data->radius * 1.2, data->radius * 1.2, data->radius * 1.2);
    Mesh* m = Mesh::getMesh("half_sphere.obj");
    m->render();
    glPopMatrix();
#endif//FEATURE_3D_RENDERING
}
