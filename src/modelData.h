#ifndef MODEL_DATA_H
#define MODEL_DATA_H

#include <SFML/System.hpp>
#include <unordered_map>

#include "engine.h"

#include "mesh.h"

class SpaceObject;

class EngineEmitterData
{
public:
    sf::Vector3f position;
    sf::Vector3f color;
    float scale;

    EngineEmitterData(sf::Vector3f position, sf::Vector3f color, float scale) : position(position), color(color), scale(scale) {}
};

class ModelData : public PObject
{
private:
    static std::unordered_map<string, P<ModelData> > data_map;
public:
    static P<ModelData> getModel(string name) { return data_map[name];}

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
    std::vector<EngineEmitterData> engine_emitters;
public:
    ModelData();

    void setName(string name);
    void setMesh(string mesh_name);

    /*!
     * Set the texture (by name)
     */
    void setTexture(string texture_name);

    /*!
     * Set the specular texture (by name)
     */
    void setSpecular(string specular_texture_name);

    /*!
     * Set the Illumination texture (by name)
     */
    void setIllumination(string illumination_texture_name);

    /*!
     * \brief Set the offset by which this model data needs to be rendered.
     *
     * \param mesh_offset 3D offset of the model.
     * Not all models have the same origin, so we can use this to compensate for that.
     */
    void setRenderOffset(sf::Vector3f mesh_offset);

    /*!
     * Set the scale of the model.
     *
     * Note that this sets the uniform scale. We've not had a reason to set non-uniform scale.
     */
    void setScale(float scale);
    void setRadius(float radius);
    void setCollisionBox(sf::Vector2f collision_box);

    /*!
     * Add a beam position (location from which a beam weapon is fired
     */
    void addBeamPosition(sf::Vector3f position);

    /*!
     * Add a (missile) tube position (location from which a tube based weapon is fired
     */
    void addTubePosition(sf::Vector3f position);

    /*!
     * Add a particle emitter
     */
    void addEngineEmitor(sf::Vector3f position, sf::Vector3f color, float scale);

    sf::Vector3f getBeamPosition(int index);
    sf::Vector2f getBeamPosition2D(int index);
    sf::Vector3f getTubePosition(int index);
    sf::Vector2f getTubePosition2D(int index);
    void setCollisionData(P<SpaceObject> object);
    float getRadius();

    void load();
    void render();

    friend class ModelInfo;
};

#endif//MODEL_DATA_H
