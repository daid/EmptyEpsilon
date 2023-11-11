#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>
#include "beamEffect.h"
#include "spaceship.h"
#include "mesh.h"
#include "random.h"
#include "main.h"
#include "textureManager.h"
#include "soundManager.h"
#include "multiplayer_server.h"
#include "multiplayer_client.h"

#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>

struct VertexAndTexCoords
{
    glm::vec3 vertex;
    glm::vec2 texcoords;
};

/// A BeamEffect is a beam weapon firing audio/visual effect that fades after its duration expires.
/// This is a cosmetic effect and does not deal damage on its own.
/// Example: beamfx = BeamEffect():setSource(player,0,0,0):setTarget(enemy,0,0,0)
REGISTER_SCRIPT_SUBCLASS(BeamEffect, SpaceObject)
{
    /// Sets the BeamEffect's origin SpaceObject.
    /// Requires a 3D x/y/z vector positional offset relative to the object's origin point.
    /// Example: beamfx:setSource(0,0,0)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setSource);
    /// Sets the BeamEffect's target SpaceObject.
    /// Requires a 3D x/y/z vector positional offset relative to the object's origin point.
    /// Example: beamfx:setTarget(target,0,0,0)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setTarget);
    /// Sets the BeamEffect's texture.
    /// Valid values are filenames of PNG files relative to the resources/ directory.
    /// Defaults to "texture/beam_orange.png".
    /// Example: beamfx:setTexture("beam_blue.png")
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setTexture);
    /// Sets the BeamEffect's sound effect.
    /// Valid values are filenames of WAV files relative to the resources/ directory.
    /// Defaults to "sfx/laser_fire.wav".
    /// Example: beamfx:setBeamFireSound("sfx/hvli_fire.wav")
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setBeamFireSound);
    /// Sets the magnitude of the BeamEffect's sound effect.
    /// Defaults to 1.0.
    /// Larger values are louder and can be heard from larger distances.
    /// This value also affects the sound effect's pitch.
    /// Example: beamfx:setBeamFireSoundPower(0.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setBeamFireSoundPower);
    /// Sets the BeamEffect's duration, in seconds.
    /// Defaults to 1.0.
    /// Example: beamfx:setDuration(1.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setDuration);
    /// Defines whether the BeamEffect generates an impact ring on the target end.
    /// Defaults to true.
    /// Example: beamfx:setRing(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setRing);
}

REGISTER_MULTIPLAYER_CLASS(BeamEffect, "BeamEffect");
BeamEffect::BeamEffect()
: SpaceObject(1000, "BeamEffect")
{
    has_weight = false;
    setRadarSignatureInfo(0.0, 0.3, 0.0);
    setCollisionRadius(1.0);
    lifetime = 1.0;
    sourceId = -1;
    target_id = -1;
    beam_texture = "texture/beam_orange.png";
    beam_fire_sound = "sfx/laser_fire.wav";
    beam_fire_sound_power = 1;
    beam_sound_played = false;
    fire_ring = true;
    registerMemberReplication(&lifetime, 0.1);
    registerMemberReplication(&sourceId);
    registerMemberReplication(&target_id);
    registerMemberReplication(&sourceOffset);
    registerMemberReplication(&targetOffset);
    registerMemberReplication(&targetLocation, 1.0);
    registerMemberReplication(&hitNormal);
    registerMemberReplication(&beam_texture);
    registerMemberReplication(&beam_fire_sound);
    registerMemberReplication(&beam_fire_sound_power);
    registerMemberReplication(&fire_ring);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
BeamEffect::~BeamEffect()
{
}

void BeamEffect::draw3DTransparent()
{
    glm::vec3 startPoint(getPosition().x, getPosition().y, sourceOffset.z);
    glm::vec3 endPoint(targetLocation.x, targetLocation.y, targetOffset.z);
    glm::vec3 eyeNormal = glm::normalize(glm::cross(camera_position - startPoint, endPoint - startPoint));

    textureManager.getTexture(beam_texture)->bind();

    ShaderRegistry::ScopedShader beamShader(ShaderRegistry::Shaders::Basic);

    glUniform4f(beamShader.get().uniform(ShaderRegistry::Uniforms::Color), lifetime, lifetime, lifetime, 1.f);
    glUniformMatrix4fv(beamShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(getModelMatrix()));
    
    gl::ScopedVertexAttribArray positions(beamShader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(beamShader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    std::array<VertexAndTexCoords, 4> quad;
    // Beam
    {
        glm::vec3 v0 = startPoint + eyeNormal * 4.0f;
        glm::vec3 v1 = endPoint + eyeNormal * 4.0f;
        glm::vec3 v2 = endPoint - eyeNormal * 4.0f;
        glm::vec3 v3 = startPoint - eyeNormal * 4.0f;
        quad[0].vertex = v0;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v1;
        quad[1].texcoords = { 0.f, 1.f };
        quad[2].vertex = v2;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v3;
        quad[3].texcoords = { 1.f, 0.f };

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        // Draw the beam
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));

    }

    // Fire ring
    if (fire_ring)
    {
        glm::vec3 side = glm::cross(hitNormal, glm::vec3(0, 0, 1));
        glm::vec3 up = glm::cross(side, hitNormal);

        glm::vec3 v0(targetLocation.x, targetLocation.y, targetOffset.z);

        float ring_size = Tween<float>::easeOutCubic(lifetime, 1.0, 0.0, 10.0f, 80.0f);
        auto v1 = v0 + side * ring_size + up * ring_size;
        auto v2 = v0 - side * ring_size + up * ring_size;
        auto v3 = v0 - side * ring_size - up * ring_size;
        auto v4 = v0 + side * ring_size - up * ring_size;

        quad[0].vertex = v1;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v2;
        quad[1].texcoords = { 1.f, 0.f };
        quad[2].vertex = v3;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v4;
        quad[3].texcoords = { 0.f, 1.f };

        textureManager.getTexture("texture/fire_ring.png")->bind();
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

void BeamEffect::update(float delta)
{
    P<SpaceObject> source, target;
    if (game_server)
    {
        source = game_server->getObjectById(sourceId);
        target = game_server->getObjectById(target_id);
    }else{
        source = game_client->getObjectById(sourceId);
        target = game_client->getObjectById(target_id);
    }
    if (source)
        setPosition(source->getPosition() + rotateVec2(glm::vec2(sourceOffset.x, sourceOffset.y), source->getRotation()));
    if (target)
        targetLocation = target->getPosition() + glm::vec2(targetOffset.x, targetOffset.y);

    if (source && delta > 0 && !beam_sound_played)
    {
        float volume = 50.0f + (beam_fire_sound_power * 75.0f);
        float pitch = (1.0f / beam_fire_sound_power) + random(-0.1f, 0.1f);
        soundManager->playSound(beam_fire_sound, source->getPosition(), 400.0, 0.6, pitch, volume);
        beam_sound_played = true;
    }

    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}

void BeamEffect::setSource(P<SpaceObject> source, glm::vec3 offset)
{
    if (source)
    {
        sourceId = source->getMultiplayerId();
        sourceOffset = offset;
        update(0);
    }
    else
    {
        LOG(DEBUG) << "BeamEffect attempted with no target";
    }
}

void BeamEffect::setTarget(P<SpaceObject> target, glm::vec2 hitLocation)
{
    if (target)
    {
        target_id = target->getMultiplayerId();
        float r = target->getRadius();
        hitLocation -= target->getPosition();
        targetOffset = glm::vec3(hitLocation.x + random(-r/2.0f, r/2.0f), hitLocation.y + random(-r/2.0f, r/2.0f), random(-r/4.0f, r/4.0f));

        if (target->hasShield())
            targetOffset = glm::normalize(targetOffset) * r;
        else
            targetOffset = glm::normalize(targetOffset) * random(0, r / 2.0f);
        update(0);

        glm::vec3 hitPos(targetLocation.x, targetLocation.y, targetOffset.z);
        glm::vec3 targetPos(target->getPosition().x, target->getPosition().y, 0);
        hitNormal = glm::normalize(targetPos - hitPos);
    }
    else
    {
        LOG(DEBUG) << "BeamEffect attempted with no target";
    }
}

glm::mat4 BeamEffect::getModelMatrix() const
{
    auto position = getPosition();
    return glm::translate(SpaceObject::getModelMatrix(), -glm::vec3(position.x, position.y, 0.f));
}
