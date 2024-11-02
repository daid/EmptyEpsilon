#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>

#include "textureManager.h"
#include "main.h"

#include "spaceObjects/spaceObject.h"
#include "modelData.h"

#include "scriptInterface.h"
#include "glObjects.h"

/// A ModelData object contains 3D appearance and SeriousProton physics collision details.
/// Almost all SpaceObjects have a ModelData associated with them to define how they appear in 3D views.
/// A ScienceDatabase entry can also have ModelData associated with and displayed in it.
///
/// This defines a 3D mesh file, an albedo map ("texture"), a specular map, and an illumination map.
/// These files might be located in the resources/ directory or loaded from resource packs.
///
/// ModelData also defines the model's position offset and scale relative to its mesh coordinates.
/// If the model is for a SpaceShip with weapons or thrusters, this also defines the origin positions of its weapon effects, and particle emitters for thruster and engine effects.
/// For physics, this defines the model's radius for a circle collider, or optional box collider dimensions.
/// (While ModelData defines 3D models, EmptyEpsilon uses a 2D physics engine for collisions.)
/// 
/// EmptyEpsilon loads ModelData from scripts/model_data.lua when launched, and loads meshes and textures when an object using this ModelData is first viewed.
///  
/// For complete examples, see scripts/model_data.lua.
REGISTER_SCRIPT_CLASS(ModelData)
{
    /// Sets this ModelData's name.
    /// Use this name when referencing a ModelData from other objects.
    /// Example: model:setName("space_station_1")
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setName);
    /// Sets this ModelData's mesh file.
    /// Required; if omitted, this ModelData generates an error.
    /// Valid values include OBJ-format (.obj extension) 3D models relative to the resources/ directory.
    /// You can also reference models from resource packs, which have ".model" extensions.
    /// To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | grep -i model"  on *nix.
    /// For example, this lists "battleship_destroyer_2_upgraded/battleship_destroyer_2_upgraded.model", which is a valid mesh path.
    /// Examples:
    /// setMesh("space_station_1/space_station_1.model") -- loads this model from a resource pack
    /// setMesh("mesh/sphere.obj") -- loads this model from the resources/ directory
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setMesh);
    /// Sets this ModelData's albedo map, or base flat-light color texture.
    /// Required; if omitted, this ModelData generates an error.
    /// Valid values include PNG- or JPG-format images relative to the resources/ directory.
    /// You can also reference textures from resource packs.
    /// To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
    /// Examples:
    /// model:setTexture("space_station_1/space_station_1_color.jpg") -- loads this texture from a resource pack
    /// model:setTexture("mesh/ship/Ender Battlecruiser.png") -- loads this texture from the resources/ directory
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setTexture);
    /// Sets this ModelData's specular map, or shininess texture.
    /// Optional; if omitted, no specular map is applied.
    /// Valid values include PNG- or JPG-format images relative to the resources/ directory.
    /// You can also reference textures from resource packs.
    /// To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
    /// Examples:
    /// model:setSpecular("space_station_1/space_station_1_specular.jpg") -- loads this texture from a resource pack
    /// model:setSpecular("mesh/various/debris-blog-specular.jpg") -- loads this texture from the resources/ directory
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setSpecular);
    /// Sets this ModelData's illumination map, or glow texture, which defines which parts of the texture appear to be luminescent.
    /// Optional; if omitted, no illumination map is applied.
    /// Valid values include PNG- or JPG-format images relative to the resources/ directory.
    /// You can also reference textures from resource packs.
    /// To view resource pack paths, extract strings from the pack, such as by running "strings packs/Angryfly.pack | egrep -i (png|jpg)" on *nix.
    /// Examples:
    /// model:setIllumination("space_station_1/space_station_1_illumination.jpg") -- loads this texture from a resource pack
    /// model:setIllumination("mesh/ship/Ender Battlecruiser_illumination.png") -- loads this texture from the resources/ directory
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setIllumination);
    /// Sets this ModelData's mesh offset, relative to its position in its mesh data.
    /// If a 3D mesh's central origin point is not at 0,0,0, use this to compensate.
    /// If you view the model in Blender, these values are equivalent to -X,+Y,+Z.
    /// Example: model:setRenderOffset(1,2,5) -- offsets its in-game position from its mesh file position when rendered
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setRenderOffset);
    /// Scales this ModelData's mesh by the given factor.
    /// Values greater than 1.0 scale the model up, and values between 0 and 1.0 scale it down.
    /// Use this if models you load are smaller or larger than expected.
    /// Defaults to 1.0.
    /// Example: model:setScale(20) -- scales the model up by 20x
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setScale);
    /// Sets this ModelData's base radius.
    /// By default, EmptyEpsilon uses this to create a circular collider around objects that use this ModelData.
    /// SpaceObject:setRadius() can override this for colliders.
    /// Setting a box collider with ModelData:setCollisionBox() also overrides this.
    /// Defaults to 1.0.
    /// Example: model:setRadius(100) -- sets the object's collisionable radius to 0.1U
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setRadius);
    /// Sets a 2D box collider for this ModelData.
    /// If both values are greater than 0.0, this overrides ModelData:setRadius() for collisions.
    /// Defaults to 0,0.
    /// Example: model:setCollisionBox(400, 400) -- sets the object's collision box to 0.4U by 0.4U
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, setCollisionBox);
    /// Adds a BeamEffect origin position to this ModelData.
    /// If no origin positions are defined, this defaults to the model's origin (0,0,0).
    /// If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
    /// Example:
    /// -- Add a beam position at the given model X/Y/Z coordinates.
    /// model:addBeamPosition(21,-28.2,-2)
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addBeamPosition);
    /// Adds a WeaponTube origin position to this ModelData.
    /// If no origin positions are defined, this defaults to the model's origin (0,0,0).
    /// If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
    /// -- Add a tube position at the given model X/Y/Z coordinates.
    /// model:addTubePosition(21,-28.2,-2)
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addTubePosition);
    /// [DEPRECATED]
    /// Use ModelData:addEngineEmitter().
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addEngineEmitor);
    /// Adds an impulse engine particle effect emitter to this ModelData.
    /// When a SpaceShip engages impulse engines, this defines the position, color, and size of a particle trail effect.
    /// If no origin positions are defined, this defaults to the model's origin (0,0,0).
    /// If you view the model in Blender, these coordinate values are equivalent to -X,+Y,+Z.
    /// Example:
    /// -- Add an engine emitter at the given model X/Y/Z coordinates, with a RGB color of 1.0/0.2/0.2 and scale of 3.
    /// model:addEngineEmitter(-28, 1.5,-5,1.0,0.2,0.2,3.0)
    REGISTER_SCRIPT_CLASS_FUNCTION(ModelData, addEngineEmitter);
}

std::unordered_map<string, P<ModelData> > ModelData::data_map;

ModelData::ModelData()
:
    loaded(false), mesh(nullptr),
    texture(nullptr), specular_texture(nullptr), illumination_texture(nullptr),
    shader_id(ShaderRegistry::Shaders::Count),
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

void ModelData::setRenderOffset(glm::vec3 mesh_offset)
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

void ModelData::setCollisionBox(glm::vec2 collision_box)
{
    this->collision_box = collision_box;
}

void ModelData::addBeamPosition(glm::vec3 position)
{
    beam_position.push_back(position);
}

void ModelData::addTubePosition(glm::vec3 position)
{
    tube_position.push_back(position);
}

void ModelData::addEngineEmitter(glm::vec3 position, glm::vec3 color, float scale)
{
    engine_emitters.push_back(EngineEmitterData(position, color, scale));
}

void ModelData::addEngineEmitor(glm::vec3 position, glm::vec3 color, float scale)
{
    LOG(WARNING) << "Deprecated function addEngineEmitor called. Use addEngineEmitter instead.";
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

glm::vec3 ModelData::getBeamPosition(int index)
{
    if (index < 0 || index >= (int)beam_position.size())
        return glm::vec3(0.0f, 0.0f, 0.0f);
    return (beam_position[index] + mesh_offset) * scale;
}

glm::vec2 ModelData::getBeamPosition2D(int index)
{
    if (index < 0 || index >= (int)beam_position.size())
        return glm::vec2(0.0f, 0.0f);
    return glm::vec2(beam_position[index].x + mesh_offset.x, beam_position[index].y + mesh_offset.y) * scale;
}

glm::vec3 ModelData::getTubePosition(int index)
{
    if (index < 0 || index >= (int)tube_position.size())
        return glm::vec3(0.0f, 0.0f, 0.0f);
    return (tube_position[index] + mesh_offset) * scale;
}

glm::vec2 ModelData::getTubePosition2D(int index)
{
    if (index < 0 || index >= (int)tube_position.size())
        return glm::vec2(0.0f, 0.0f);
    return glm::vec2(tube_position[index].x + mesh_offset.x, tube_position[index].y + mesh_offset.y) * scale;
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
            shader_id = ShaderRegistry::Shaders::ObjectSpecularIllumination;
        else if (texture && specular_texture)
            shader_id = ShaderRegistry::Shaders::ObjectSpecular;
        else if (texture && illumination_texture)
            shader_id = ShaderRegistry::Shaders::ObjectIllumination;
        else
            shader_id = ShaderRegistry::Shaders::Object;
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

void ModelData::render(const glm::mat4& model_matrix)
{
    load();
    if (!mesh)
        return;

    // EE's coordinate flips to a Z-up left hand.
    // To account for that, flip the model around 180deg.
    auto modeldata_matrix = glm::rotate(model_matrix, glm::radians(180.f), {0.f, 0.f, 1.f});
    modeldata_matrix = glm::scale(modeldata_matrix, glm::vec3{scale});
    modeldata_matrix = glm::translate(modeldata_matrix, mesh_offset);

    ShaderRegistry::ScopedShader shader(shader_id);
    glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(modeldata_matrix));


    // Lights setup.
    ShaderRegistry::setupLights(shader.get(), model_matrix);

    // Textures
    texture->bind();

    if (specular_texture)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::SpecularMap));
        specular_texture->bind();
    }

    if (illumination_texture)
    {
        glActiveTexture(GL_TEXTURE0 + ShaderRegistry::textureIndex(ShaderRegistry::Textures::IlluminationMap));
        illumination_texture->bind();
    }

    // Draw
    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));
    gl::ScopedVertexAttribArray normals(shader.get().attribute(ShaderRegistry::Attributes::Normal));

    
    mesh->render(positions.get(), texcoords.get(), normals.get());

    if (specular_texture || illumination_texture)
        glActiveTexture(GL_TEXTURE0);
}
