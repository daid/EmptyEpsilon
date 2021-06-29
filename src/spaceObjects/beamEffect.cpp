#include <GL/glew.h>
#include <SFML/OpenGL.hpp>
#include "beamEffect.h"
#include "spaceship.h"
#include "mesh.h"
#include "main.h"

#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>

#if FEATURE_3D_RENDERING
struct VertexAndTexCoords
{
    sf::Vector3f vertex;
    sf::Vector2f texcoords;
};
#endif

/// BeamEffect is a beam weapon fire effect that will fade after 1 seond
/// Example: BeamEffect():setSource(player):setTarget(enemy_ship)
REGISTER_SCRIPT_SUBCLASS(BeamEffect, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setSource);
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setBeamFireSound);
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setBeamFireSoundPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setDuration);
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
    beam_texture = "beam_orange.png";
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

#if FEATURE_3D_RENDERING
void BeamEffect::draw3DTransparent()
{
    glTranslatef(-getPosition().x, -getPosition().y, 0);
    sf::Vector3f startPoint(getPosition().x, getPosition().y, sourceOffset.z);
    sf::Vector3f endPoint(targetLocation.x, targetLocation.y, targetOffset.z);
    sf::Vector3f eyeNormal = sf::normalize(sf::cross(camera_position - startPoint, endPoint - startPoint));

    glBindTexture(GL_TEXTURE_2D, textureManager.getTexture(beam_texture)->getNativeHandle());

    ShaderRegistry::ScopedShader beamShader(ShaderRegistry::Shaders::Basic);

    glUniform4f(beamShader.get().uniform(ShaderRegistry::Uniforms::Color), lifetime, lifetime, lifetime, 1.f);
    
    gl::ScopedVertexAttribArray positions(beamShader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(beamShader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    std::array<VertexAndTexCoords, 4> quad;
    // Beam
    {
        sf::Vector3f v0 = startPoint + eyeNormal * 4.0f;
        sf::Vector3f v1 = endPoint + eyeNormal * 4.0f;
        sf::Vector3f v2 = endPoint - eyeNormal * 4.0f;
        sf::Vector3f v3 = startPoint - eyeNormal * 4.0f;
        quad[0].vertex = v0;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v1;
        quad[1].texcoords = { 0.f, 1.f };
        quad[2].vertex = v2;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v3;
        quad[3].texcoords = { 1.f, 0.f };

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(sf::Vector3f)));
        // Draw the beam
        std::initializer_list<uint8_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, std::begin(indices));

    }

    // Fire ring
    if (fire_ring)
    {
        sf::Vector3f side = sf::cross(hitNormal, sf::Vector3f(0, 0, 1));
        sf::Vector3f up = sf::cross(side, hitNormal);

        sf::Vector3f v0(targetLocation.x, targetLocation.y, targetOffset.z);

        float ring_size = Tween<float>::easeOutCubic(lifetime, 1.0, 0.0, 10.0f, 80.0f);
        sf::Vector3f v1 = v0 + side * ring_size + up * ring_size;
        sf::Vector3f v2 = v0 - side * ring_size + up * ring_size;
        sf::Vector3f v3 = v0 - side * ring_size - up * ring_size;
        sf::Vector3f v4 = v0 + side * ring_size - up * ring_size;

        quad[0].vertex = v1;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v2;
        quad[1].texcoords = { 1.f, 0.f };
        quad[2].vertex = v3;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v4;
        quad[3].texcoords = { 0.f, 1.f };

        glBindTexture(GL_TEXTURE_2D, textureManager.getTexture("fire_ring.png")->getNativeHandle());
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(sf::Vector3f)));
        std::initializer_list<uint8_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, std::begin(indices));
    }
}
#endif//FEATURE_3D_RENDERING

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
        soundManager->playSound(beam_fire_sound, source->getPosition(), 400.0, 60.0, pitch, volume);
        beam_sound_played = true;
    }

    lifetime -= delta;
    if (lifetime < 0)
        destroy();
}

void BeamEffect::setSource(P<SpaceObject> source, sf::Vector3f offset)
{
    sourceId = source->getMultiplayerId();
    sourceOffset = offset;
    update(0);
}

void BeamEffect::setTarget(P<SpaceObject> target, glm::vec2 hitLocation)
{
    target_id = target->getMultiplayerId();
    float r = target->getRadius();
    hitLocation -= target->getPosition();
    targetOffset = sf::Vector3f(hitLocation.x + random(-r/2.0, r/2.0), hitLocation.y + random(-r/2.0, r/2.0), random(-r/4.0, r/4.0));

    if (target->hasShield())
        targetOffset = sf::normalize(targetOffset) * r;
    else
        targetOffset = sf::normalize(targetOffset) * random(0, r / 2.0);
    update(0);

    sf::Vector3f hitPos(targetLocation.x, targetLocation.y, targetOffset.z);
    sf::Vector3f targetPos(target->getPosition().x, target->getPosition().y, 0);
    hitNormal = sf::normalize(targetPos - hitPos);
}

glm::mat4 BeamEffect::getModelMatrix() const
{
    auto position = getPosition();
    return glm::translate(SpaceObject::getModelMatrix(), -glm::vec3(position.x, position.y, 0.f));
}
