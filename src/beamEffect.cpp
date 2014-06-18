#include <SFML/OpenGL.hpp>
#include "beamEffect.h"
#include "spaceship.h"
#include "mesh.h"
#include "main.h"

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

void BeamEffect::draw3DTransparent()
{
    sf::Shader::bind(NULL);
    sf::Texture::bind(NULL);
    
    sf::Vector2f v = targetLocation - getPosition();
    sf::Vector2f normal = sf::normalize(v);
    sf::Vector2f offset(normal.y * 4.0f, -normal.x * 4.0f);
    glColor3f(lifetime, lifetime, lifetime);
    glBegin(GL_QUADS);
    glVertex3f(v.x + offset.x, v.y + offset.y, targetOffset.z);
    glVertex3f(offset.x, offset.y, sourceOffset.z);
    glVertex3f(-offset.x, -offset.y, sourceOffset.z);
    glVertex3f(v.x - offset.x, v.y - offset.y, targetOffset.z);
    glEnd();
    
    P<SpaceObject> target = gameServer->getObjectById(targetId);
    sf::Vector3f hitPos(targetLocation.x, targetLocation.y, targetOffset.z);
    sf::Vector3f targetPos(target->getPosition().x, target->getPosition().y, 0);
    sf::Vector3f shieldNormal = sf::normalize(targetPos - hitPos);
    
    sf::Vector3f side = sf::cross(shieldNormal, sf::Vector3f(0, 0, 1));
    sf::Vector3f up = sf::cross(side, shieldNormal);
    
    sf::Vector3f v0(v.x, v.y, targetOffset.z);
    
    sf::Vector3f v1 = v0 + side * 20.0f + up * 20.0f;
    sf::Vector3f v2 = v0 - side * 20.0f + up * 20.0f;
    sf::Vector3f v3 = v0 - side * 20.0f - up * 20.0f;
    sf::Vector3f v4 = v0 + side * 20.0f - up * 20.0f;
    
    basicShader.setParameter("textureMap", *textureManager.getTexture("fire_ring.png"));
    sf::Shader::bind(&basicShader);
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
    float r = target->getRadius();
    targetOffset = sf::Vector3f(hitLocation.x + random(-r/2.0, r/2.0), hitLocation.y + random(-r/2.0, r/2.0), random(-r/4.0, r/4.0));
    if (target->hasShield())
    {
        targetOffset = sf::normalize(targetOffset) * r;
    }
    update(0);
}
