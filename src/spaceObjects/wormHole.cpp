#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>

#include "main.h"
#include "random.h"
#include "wormHole.h"
#include "spaceship.h"
#include "scriptInterface.h"
#include "textureManager.h"
#include "components/gravity.h"
#include "components/avoidobject.h"

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

/// A WormHole is a piece of space terrain that pulls all nearby SpaceObjects within a 5U radius, including otherwise immobile objects like SpaceStations, toward its center.
/// Any SpaceObject that reaches its center is teleported to another point in space.
/// AI behaviors avoid WormHoles by a 2U margin.
/// Example: wormhole = WormHole():setPosition(1000,1000):setTargetPosition(10000,10000)
REGISTER_SCRIPT_SUBCLASS(WormHole, SpaceObject)
{
    /// Sets the target teleportation coordinates for SpaceObjects that pass through the center of this WormHole.
    /// Example: wormhole:setTargetPosition(10000,10000)
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, setTargetPosition);
    /// Returns the target teleportation coordinates for SpaceObjects that pass through the center of this WormHole.
    /// Example: wormhole:getTargetPosition()
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, getTargetPosition);
    /// Defines a function to call when this WormHole teleports a SpaceObject.
    /// Passes the WormHole object and the teleported SpaceObject.
    /// Example:
    /// -- Outputs teleportation details to the console window and logging file
    /// wormhole:onTeleportation(function(this_wormhole,teleported_object) print(teleported_object:getCallSign() .. " teleported to " .. this_wormhole:getTargetPosition()) end)
    REGISTER_SCRIPT_CLASS_FUNCTION(WormHole, onTeleportation);
}

REGISTER_MULTIPLAYER_CLASS(WormHole, "WormHole");
WormHole::WormHole()
: SpaceObject(DEFAULT_COLLISION_RADIUS, "WormHole")
{
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

    if (entity) {
        auto& g = entity.getOrAddComponent<Gravity>();
        g.damage = false;
        g.range = DEFAULT_COLLISION_RADIUS;

        entity.getOrAddComponent<AvoidObject>().range = DEFAULT_COLLISION_RADIUS * AVOIDANCE_MULTIPLIER;
    }
}

void WormHole::draw3DTransparent()
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
        auto model_matrix = glm::translate(getModelMatrix(), {cloud.offset.x, cloud.offset.y, 0});
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 2, 1, 0, 3, 2 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

void WormHole::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawRotatedSpriteBlendAdd("wormHole" + string(radar_visual) + ".png", position, 5000.0f * scale * 3.0f, getRotation() - rotation);
}

// Draw a line toward the target position
void WormHole::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    auto offset = target_position - getPosition();
    renderer.drawLine(position, position + glm::vec2(offset.x, offset.y) * scale, glm::u8vec4(255, 255, 255, 32));

    renderer.drawCircleOutline(position, 5000.0f * scale, 2.0, glm::u8vec4(255, 255, 255, 32));
}


void WormHole::update(float delta)
{
    update_delta = delta;
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
