#ifndef MODEL_DATA_H
#define MODEL_DATA_H

#include <SFML/System.hpp>
#include <unordered_map>

#include "engine.h"

#include "mesh.h"

class SpaceObject;

class EngineEmitorData
{
public:
    sf::Vector3f position;
    sf::Vector3f color;
    float scale;

    EngineEmitorData(sf::Vector3f position, sf::Vector3f color, float scale) : position(position), color(color), scale(scale) {}
};

class ModelData : public PObject
{
private:
    static std::unordered_map<string, P<ModelData> > data_map;
public:
    static P<ModelData> getModel(string name) { return data_map[name]; }

private:
    string mesh_name;
    string texture_name;
    string specular_texture_name;
    string illumination_texture_name;

    bool loaded;
    
    Mesh* mesh;
    sf::Vector3f mesh_offset;
    sf::Texture* texture;
    sf::Texture* specular_texture;
    sf::Texture* illumination_texture;
    sf::Shader* shader;
    float scale;
    
    float radius;
    /*!
     * \brief 2D colission box of the ship.
     * As the game is only 2D, we only need a width & height that indicates the collission object.
     */
    sf::Vector2f collision_box;
    
    std::vector<sf::Vector3f> beam_position;
    std::vector<sf::Vector3f> tube_position;
    std::vector<EngineEmitorData> engine_emitors;
public:
    ModelData();

    void setName(string name);
    void setMesh(string mesh_name) { this->mesh_name = mesh_name; }
    void setTexture(string texture_name) { this->texture_name = texture_name; }
    void setSpecular(string specular_texture_name) { this->specular_texture_name = specular_texture_name; }
    void setIllumination(string illumination_texture_name) { this->illumination_texture_name = illumination_texture_name; }
    void setRenderOffset(sf::Vector3f mesh_offset) { this->mesh_offset = mesh_offset; }
    void setScale(float scale) { this->scale = scale; }
    void setRadius(float radius) { this->radius = radius; }
    void setCollisionBox(sf::Vector2f collision_box) { this->collision_box = collision_box; }
    
    void addBeamPosition(sf::Vector3f position) { beam_position.push_back(position); }
    void addTubePosition(sf::Vector3f position) { tube_position.push_back(position); }
    void addEngineEmitor(sf::Vector3f position, sf::Vector3f color, float scale) { engine_emitors.push_back(EngineEmitorData(position, color, scale)); }
    
    
    sf::Vector3f getBeamPosition(int index);
    sf::Vector2f getBeamPosition2D(int index);
    sf::Vector3f getTubePosition(int index);
    sf::Vector2f getTubePosition2D(int index);
    void setCollisionData(P<SpaceObject> object);
    float getRadius() { return radius; }

    void load();
    void render();
    
    friend class ModelInfo;
};

#endif//MODEL_DATA_H
