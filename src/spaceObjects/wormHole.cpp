#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>

#include "main.h"
#include "wormHole.h"
#include "spaceship.h"
#include "scriptInterface.h"

#include "glObjects.h"
#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>

#define FORCE_MULTIPLIER          50.0f
#define FORCE_MAX                 10000.0f
#define ALPHA_MULTIPLIER          10.0f
#define DEFAULT_COLLISION_RADIUS  2500.0f
#define AVOIDANCE_MULTIPLIER      1.2f
#define TARGET_SPREAD             500.0f

struct VertexAndTexCoords
{
    glm::vec3 vertex;
    glm::vec2 texcoords;
};

/// A wormhole object that drags objects toward it like a black hole, and then
/// teleports them to another point when they reach its center.
REGISTER_SCRIPT_SUBCLASS(WormHole, SpaceObject)
{
    /// Set the target of this wormhole
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, setTargetPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, getTargetPosition);
    /// Set a function that will be called if a SpaceObject is teleported.
    /// First argument given to the function will be the WormHole, the second the SpaceObject that has been teleported.
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, onTeleportation);
}

REGISTER_MULTIPLAYER_CLASS(WormHole, "WormHole");
WormHole::WormHole()
: SpaceObject(DEFAULT_COLLISION_RADIUS, "WormHole")
{
    pathPlanner = PathPlannerManager::getInstance();
    pathPlanner->addAvoidObject(this, (DEFAULT_COLLISION_RADIUS * AVOIDANCE_MULTIPLIER) );

    setRadarSignatureInfo(0.9, 0.0, 0.0);

    // Choose a texture to show on radar
    radar_visual = irandom(1, 3);
    registerMemberReplication(&radar_visual);

    // Create some overlaying clouds
    for(int n=0; n<cloud_count; n++)
    {
        clouds[n].size = random(1024, 1024 * 4);
        clouds[n].texture = irandom(1, 3);
        clouds[n].offset = glm::vec2(0, 0);
    }
}

void WormHole::draw3DTransparent(const glm::mat4& object_view_matrix)
{
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    for(int n=0; n<cloud_count; n++)
    {
        NebulaCloud& cloud = clouds[n];

        auto position = glm::vec3(getPosition().x, getPosition().y, 0) + glm::vec3(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;

        float distance = glm::length(camera_position - position);
        float alpha = 1.0f - (distance / 10000.0f);
        if (alpha < 0.0f)
            continue;

        textureManager.getTexture("wormHole" + string(cloud.texture) + ".png")->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        auto model_matrix = glm::translate(glm::mat4(1.0f), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().get()->getUniformLocation("view"), 1, GL_FALSE, glm::value_ptr(object_view_matrix * model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint8_t> indices = { 0, 2, 1, 0, 3, 2 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, std::begin(indices));
    }
}

void WormHole::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawRotatedSpriteBlendAdd("wormHole" + string(radar_visual) + ".png", position, getRotation() - rotation, getRadius() * scale * 3.0f);
}

// Draw a line toward the target position
void WormHole::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    auto offset = target_position - getPosition();
    renderer.drawLine(position, position + glm::vec2(offset.x, offset.y) * scale, glm::u8vec4(255, 255, 255, 32));

    renderer.drawCircleOutline(position, getRadius() * scale, 2.0, glm::u8vec4(255, 255, 255, 32));
}


void WormHole::update(float delta)
{
    update_delta = delta;
}

void WormHole::collide(Collisionable* target, float collision_force)
{
    if (update_delta == 0.0f)
        return;

    P<SpaceObject> obj = P<Collisionable>(target);
    if (!obj) return;
    if (!obj->hasWeight()) { return; } // the object is not affected by gravitation

    auto diff = getPosition() - target->getPosition();
    float distance = glm::length(diff);
    float force = (getRadius() * getRadius() * FORCE_MULTIPLIER) / (distance * distance);

    P<SpaceShip> spaceship = P<Collisionable>(target);

    // Warp postprocessor-alpha is calculated using alpha = (1 - (delay/10))
    if (spaceship)
        spaceship->wormhole_alpha = ((distance / getRadius()) * ALPHA_MULTIPLIER);

    if (force > FORCE_MAX)
    {
        force = FORCE_MAX;
        if (isServer())
            target->setPosition( (target_position +
                                  glm::vec2(random(-TARGET_SPREAD, TARGET_SPREAD), random(-TARGET_SPREAD, TARGET_SPREAD))));
        if (on_teleportation.isSet())
        {
            on_teleportation.call<void>(P<WormHole>(this), obj);
        }
        if (spaceship)
        {
            spaceship->wormhole_alpha = 0.0;
        }
    }

    // TODO: Escaping is impossible. Change setPosition to something Newtonianish.
    target->setPosition(target->getPosition() + diff / distance * update_delta * force);
}

void WormHole::setTargetPosition(glm::vec2 v)
{
    target_position = v;
}

glm::vec2 WormHole::getTargetPosition()
{
    return target_position;
}

void WormHole::onTeleportation(ScriptSimpleCallback callback)
{
    this->on_teleportation = callback;
}

glm::mat4 WormHole::getModelMatrix() const
{
    return glm::identity<glm::mat4>();
}
