#include <GL/glew.h>
#include <SFML/OpenGL.hpp>

#include "engine.h"
#include "main.h"

#include "spaceObjects/spaceObject.h"
#include "modelData.h"

#include "scriptInterface.h"
#include "glObjects.h"

REGISTER_SCRIPT_CLASS(ModelData)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setMesh);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setSpecular);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setIllumination);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setRenderOffset);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setScale);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setRadius);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setCollisionBox);

    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addBeamPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addTubePosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addEngineEmitor);
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addEngineEmitter);
}

std::unordered_map<string, P<ModelData> > ModelData::data_map;

ModelData::ModelData()
:
    loaded(false), mesh(nullptr),
    texture(nullptr), specular_texture(nullptr), illumination_texture(nullptr),
#if FEATURE_3D_RENDERING
    shader_id(ShaderRegistry::Shaders::Count),
#endif
scale(1.f), radius(1.f)
{
}

void ModelData::setName(string name)
{
    this->name = name;

    if (data_map.find(name) != data_map.end())
    {
        LOG(ERROR) << "Duplicate modeldata definition: " << name;
    }
    data_map[name] = this;
}

string ModelData::getName()
{
    return name;
}

void ModelData::setMesh(string mesh_name)
{
    this->mesh_name = mesh_name;
}

void ModelData::setTexture(string texture_name)
{
    this->texture_name = texture_name;
}

void ModelData::setIllumination(string illumination_texture_name)
{
    this->illumination_texture_name = illumination_texture_name;
}

void ModelData::setRenderOffset(sf::Vector3f mesh_offset)
{
     this->mesh_offset = mesh_offset;
}

void ModelData::setScale(float scale)
{
    this->scale = scale;
}

void ModelData::setRadius(float radius)
{
    this->radius = radius;
}

void ModelData::setCollisionBox(sf::Vector2f collision_box)
{
    this->collision_box = collision_box;
}

void ModelData::addBeamPosition(sf::Vector3f position)
{
    beam_position.push_back(position);
}

void ModelData::addTubePosition(sf::Vector3f position)
{
    tube_position.push_back(position);
}

void ModelData::addEngineEmitter(sf::Vector3f position, sf::Vector3f color, float scale)
{
    engine_emitters.push_back(EngineEmitterData(position, color, scale));
}

void ModelData::addEngineEmitor(sf::Vector3f position, sf::Vector3f color, float scale)
{
    LOG(WARNING) << "Depricated function addEngineEmitor called. Use addEngineEmitter instead.";
    addEngineEmitter(position, color, scale);
}

float ModelData::getRadius()
{
    return radius;
}

void ModelData::setSpecular(string specular_texture_name)
{
     this->specular_texture_name = specular_texture_name;
}
void ModelData::setCollisionData(P<SpaceObject> object)
{
    object->setRadius(radius);
    if (collision_box.x > 0 && collision_box.y > 0)
        object->setCollisionBox(collision_box);
}

sf::Vector3f ModelData::getBeamPosition(int index)
{
    if (index < 0 || index >= (int)beam_position.size())
        return sf::Vector3f(0.0f, 0.0f, 0.0f);
    return (beam_position[index] + mesh_offset) * scale;
}

sf::Vector2f ModelData::getBeamPosition2D(int index)
{
    if (index < 0 || index >= (int)beam_position.size())
        return sf::Vector2f(0.0f, 0.0f);
    return sf::Vector2f(beam_position[index].x + mesh_offset.x, beam_position[index].y + mesh_offset.y) * scale;
}

sf::Vector3f ModelData::getTubePosition(int index)
{
    if (index < 0 || index >= (int)tube_position.size())
        return sf::Vector3f(0.0f, 0.0f, 0.0f);
    return (tube_position[index] + mesh_offset) * scale;
}

sf::Vector2f ModelData::getTubePosition2D(int index)
{
    if (index < 0 || index >= (int)tube_position.size())
        return sf::Vector2f(0.0f, 0.0f);
    return sf::Vector2f(tube_position[index].x + mesh_offset.x, tube_position[index].y + mesh_offset.y) * scale;
}

void ModelData::load()
{
    if (!loaded)
    {
        mesh = Mesh::getMesh(mesh_name);
        texture = textureManager.getTexture(texture_name);
        if (specular_texture_name != "")
            specular_texture = textureManager.getTexture(specular_texture_name);
        if (illumination_texture_name != "")
            illumination_texture = textureManager.getTexture(illumination_texture_name);
#if FEATURE_3D_RENDERING
        if (texture && specular_texture && illumination_texture)
            shader_id = ShaderRegistry::Shaders::ObjectSpecularIllumination;
        else if (texture && specular_texture)
            shader_id = ShaderRegistry::Shaders::ObjectSpecular;
        else if (texture && illumination_texture)
            shader_id = ShaderRegistry::Shaders::ObjectIllumination;
        else
            shader_id = ShaderRegistry::Shaders::Object;
#endif
        loaded = true;
    }
}

P<ModelData> ModelData::getModel(string name)
{
    if (data_map.find(name) == data_map.end())
    {
        LOG(ERROR) << "Failed to find model data: " << name;
        data_map[name] = new ModelData();
    }
    return data_map[name];
}

std::vector<string> ModelData::getModelDataNames()
{
    std::vector<string> ret;
    ret.reserve(data_map.size());
    for(const auto &it : data_map)
    {
        ret.emplace_back(it.first);
    }
    std::sort(ret.begin(), ret.end());
    return ret;
}

void ModelData::render()
{
#if FEATURE_3D_RENDERING
    load();
    if (!mesh)
        return;

    glPushMatrix();
    // EE's coordinate flips to a Z-up left hand.
    // To account for that, flip the model around 180deg.
    glRotatef(180.f, 0.f, 0.f, 1.f);
    glScalef(scale, scale, scale);
    glTranslatef(mesh_offset.x, mesh_offset.y, mesh_offset.z);

    ShaderRegistry::ScopedShader shader(shader_id);

    // Textures
    glBindTexture(GL_TEXTURE_2D, texture->getNativeHandle());

    if (specular_texture)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
        glBindTexture(GL_TEXTURE_2D, specular_texture->getNativeHandle());
    }

    if (illumination_texture)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::IlluminationMap));
        glBindTexture(GL_TEXTURE_2D, illumination_texture->getNativeHandle());
    }

    // Draw
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));
    mesh->render(positions.get(), texcoords.get(), normals.get());

    if (specular_texture || illumination_texture)
        glActiveTexture(GL_TEXTURE0);
    glPopMatrix();
#endif//FEATURE_3D_RENDERING
}
