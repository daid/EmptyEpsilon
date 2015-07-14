#include <SFML/OpenGL.hpp>

#include "engine.h"
#include "main.h"

#include "spaceObjects/spaceObject.h"
#include "modelData.h"

#include "scriptInterface.h"

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
}

std::unordered_map<string, P<ModelData> > ModelData::data_map;

ModelData::ModelData()
: loaded(false), mesh(NULL), texture(NULL), specular_texture(NULL), illumination_texture(NULL), shader(NULL), scale(1.0), radius(1.0)
{
}

void ModelData::setName(string name)
{
    if (data_map.find(name) != data_map.end())
    {
        LOG(WARNING) << "Duplicate modeldata definition: " << name;
    }
    data_map[name] = this;
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
        
        if (texture && specular_texture && illumination_texture)
            shader = &objectShader;
        else
            shader = &simpleObjectShader;
        
        loaded = true;
    }
}

void ModelData::render()
{
#if FEATURE_3D_RENDERING
    load();
    
    glPushMatrix();
    
    glScalef(scale, scale, scale);
    glTranslatef(mesh_offset.x, mesh_offset.y, mesh_offset.z);
    shader->setParameter("baseMap", *texture);
    if (specular_texture)
        shader->setParameter("specularMap", *specular_texture);
    if (illumination_texture)
        shader->setParameter("illuminationMap", *illumination_texture);
    sf::Shader::bind(shader);
    mesh->render();
    
    glPopMatrix();
#endif//FEATURE_3D_RENDERING
}
