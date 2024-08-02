#ifndef MODEL_DATA_H
#define MODEL_DATA_H

#include "graphics/texture.h"

#include "mesh.h"
#include "shaderRegistry.h"

#include <unordered_map>
#include <glm/vec3.hpp>

class EngineEmitterData
{
public:
    glm::vec3 position{};
    glm::vec3 color{};
    float scale;

    EngineEmitterData(glm::vec3 position, glm::vec3 color, float scale) : position(position), color(color), scale(scale) {}
};

class ModelData : public PObject
{
private:
    static std::unordered_map<string, P<ModelData> > data_map;
public:
    static P<ModelData> getModel(string name);
    static std::vector<string> getModelDataNames();

public:
    string name;
    string mesh_name;
    string texture_name;
    string specular_texture_name;
    string illumination_texture_name;

    bool loaded;

    Mesh* mesh;
    glm::vec3 mesh_offset{};
    sp::Texture* texture;
    sp::Texture* specular_texture;
    sp::Texture* illumination_texture;
    ShaderRegistry::Shaders shader_id;
    float scale;

    float radius;

    /*!
     * \brief 2D colission box of the ship.
     * As the game is only 2D, we only need a width & height that indicates the collission object.
     */
    glm::vec2 collision_box{0, 0};

    std::vector<glm::vec3> beam_position;
    std::vector<glm::vec3> tube_position;
    std::vector<EngineEmitterData> engine_emitters;

public:
    ModelData();

    void setName(string name);
    string getName();
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
    void setRenderOffset(glm::vec3 mesh_offset);

    /*!
     * Set the scale of the model.
     *
     * Note that this sets the uniform scale. We've not had a reason to set non-uniform scale.
     */
    void setScale(float scale);
    void setRadius(float radius);
    void setCollisionBox(glm::vec2 collision_box);

    /*!
     * Add a beam position (location from which a beam weapon is fired
     */
    void addBeamPosition(glm::vec3 position);

    /*!
     * Add a (missile) tube position (location from which a tube based weapon is fired
     */
    void addTubePosition(glm::vec3 position);

    /*!
     * Add a particle emitter
     */
    void addEngineEmitter(glm::vec3 position, glm::vec3 color, float scale);
    //Depricated
    void addEngineEmitor(glm::vec3 position, glm::vec3 color, float scale);

    glm::vec3 getBeamPosition(int index);
    glm::vec2 getBeamPosition2D(int index);
    glm::vec3 getTubePosition(int index);
    glm::vec2 getTubePosition2D(int index);
    //void setCollisionData(P<SpaceObject> object);
    float getRadius();

    void load();
    void render(const glm::mat4& model_matrix);

    friend class GuiRotatingModelView;
};

#endif//MODEL_DATA_H
