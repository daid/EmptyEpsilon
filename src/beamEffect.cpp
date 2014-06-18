#include <SFML/OpenGL.hpp>
#include "beamEffect.h"
#include "spaceship.h"
#include "mesh.h"

REGISTER_MULTIPLAYER_CLASS(BeamEffect, "BeamEffect");
BeamEffect::BeamEffect()
: SpaceObject(1, "BeamEffect")
{
    lifetime = 1.0;
    registerMemberReplication(&sourceId);
    registerMemberReplication(&targetId);
    registerMemberReplication(&sourceOffset);
    registerMemberReplication(&targetOffset);
    registerMemberReplication(&targetLocation, 1.0);
}

void BeamEffect::draw3D()
{
    sf::Shader::bind(NULL);
    sf::Texture::bind(NULL);
    
    sf::Vector2f v = targetLocation - getPosition();
    sf::Vector2f normal = sf::normalize(v);
    sf::Vector2f offset(normal.y * 4.0f, -normal.x * 4.0f);
    glBegin(GL_QUADS);
    glVertex3f(v.x + offset.x, v.y + offset.y, targetOffset.z);
    glVertex3f(offset.x, offset.y, sourceOffset.z);
    glVertex3f(-offset.x, -offset.y, sourceOffset.z);
    glVertex3f(v.x - offset.x, v.y - offset.y, targetOffset.z);
    glEnd();
}

void BeamEffect::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale)
{
}

void BeamEffect::update(float delta)
{
    P<SpaceObject> source, target;
    if (gameServer)
    {
        source = gameServer->getObjectById(sourceId);
        target = gameServer->getObjectById(targetId);
    }else{
        source = gameClient->getObjectById(sourceId);
        target = gameClient->getObjectById(targetId);
    }
    if (source)
        setPosition(source->getPosition() + rotateVector(sf::Vector2f(sourceOffset.x, sourceOffset.y), source->getRotation()));
    if (target)
        targetLocation = target->getPosition() + rotateVector(sf::Vector2f(targetOffset.x, targetOffset.y), target->getRotation());
    
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
    targetId = target->getMultiplayerId();
    targetOffset = sf::Vector3f(hitLocation.x + random(-20, 20), hitLocation.y + random(-20, 20), random(-10, 10));
    if (target->hasShield())
    {
        float r = target->getRadius();
        targetOffset = sf::normalize(targetOffset) * r;
    }
    update(0);
}
