#include <SFML/OpenGL.hpp>
#include "beamEffect.h"
#include "spaceship.h"
#include "mesh.h"
#include "main.h"

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
    setCollisionRadius(1.0);
    lifetime = 1.0;
    sourceId = -1;
    target_id = -1;
    beam_texture = "beam_orange.png";
    beam_fire_sound = "sfx/laser_fire.wav";
    beam_fire_sound_power = 1;
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

    ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture(beam_texture));
    sf::Shader::bind(ShaderManager::getShader("basicShader"));
    glColor3f(lifetime, lifetime, lifetime);
    {
        sf::Vector3f v0 = startPoint + eyeNormal * 4.0f;
        sf::Vector3f v1 = endPoint + eyeNormal * 4.0f;
        sf::Vector3f v2 = endPoint - eyeNormal * 4.0f;
        sf::Vector3f v3 = startPoint - eyeNormal * 4.0f;
        glBegin(GL_QUADS);
        glTexCoord2f(0, 0);
        glVertex3f(v0.x, v0.y, v0.z);
        glTexCoord2f(0, 1);
        glVertex3f(v1.x, v1.y, v1.z);
        glTexCoord2f(1, 1);
        glVertex3f(v2.x, v2.y, v2.z);
        glTexCoord2f(1, 0);
        glVertex3f(v3.x, v3.y, v3.z);
        glEnd();
    }

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

        ShaderManager::getShader("basicShader")->setUniform("textureMap", *textureManager.getTexture("fire_ring.png"));
        sf::Shader::bind(ShaderManager::getShader("basicShader"));
        glBegin(GL_QUADS);
        glTexCoord2f(0, 0);
        glVertex3f(v1.x, v1.y, v1.z);
        glTexCoord2f(1, 0);
        glVertex3f(v2.x, v2.y, v2.z);
        glTexCoord2f(1, 1);
        glVertex3f(v3.x, v3.y, v3.z);
        glTexCoord2f(0, 1);
        glVertex3f(v4.x, v4.y, v4.z);
        glEnd();
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
        setPosition(source->getPosition() + rotateVector(sf::Vector2f(sourceOffset.x, sourceOffset.y), source->getRotation()));
    if (target)
        targetLocation = target->getPosition() + sf::Vector2f(targetOffset.x, targetOffset.y);

    if (source && delta > 0 && lifetime == 1.0)
    {
        float volume = 50.0f + (beam_fire_sound_power * 75.0f);
        float pitch = (1.0f / beam_fire_sound_power) + random(-0.1f, 0.1f);
        soundManager->playSound(beam_fire_sound, source->getPosition(), 200.0, 1.0, pitch, volume);
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

void BeamEffect::setTarget(P<SpaceObject> target, sf::Vector2f hitLocation)
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
