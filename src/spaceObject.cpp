#include <SFML/OpenGL.hpp>
#include "spaceObject.h"

PVector<SpaceObject> spaceObjectList;

SpaceObject::SpaceObject(float collisionRange, string multiplayerName)
: Collisionable(collisionRange), MultiplayerObject(multiplayerName)
{
    objectRadius = collisionRange;
    spaceObjectList.push_back(this);
    fractionId = 0;
    
    registerMemberReplication(&fractionId);
    registerCollisionableReplication();
}

void SpaceObject::draw3D()
{
}

void SpaceObject::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange)
{
}

std::vector<NebulaInfo> nebulaInfo;

void randomNebulas()
{
    NebulaInfo info;
    nebulaInfo.clear();
    for(unsigned int n=0; n<10; n++)
    {
        info.vector = sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1));
        info.textureName = "Nebula1";
        nebulaInfo.push_back(info);
        info.vector = sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1));
        info.textureName = "Nebula2";
        nebulaInfo.push_back(info);
        info.vector = sf::Vector3f(random(-1, 1), random(-1, 1), random(-1, 1));
        info.textureName = "Nebula3";
        nebulaInfo.push_back(info);
    }
}
