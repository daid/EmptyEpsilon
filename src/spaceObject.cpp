#include <SFML/OpenGL.hpp>
#include "spaceObject.h"

PVector<SpaceObject> space_object_list;

SpaceObject::SpaceObject(float collisionRange, string multiplayerName)
: Collisionable(collisionRange), MultiplayerObject(multiplayerName)
{
    space_object_list.push_back(this);
    registerCollisionableReplication();
}

void SpaceObject::draw3D()
{
    glBegin(GL_LINES);
    glVertex3f(0, 0, -10);
    glVertex3f(0, 0,  10);
    glVertex3f(0, -50, 0);
    glVertex3f(0,  50, 0);
    glVertex3f(-50, 0, 0);
    glVertex3f( 50, 0, 0);
    glEnd();
}

void SpaceObject::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale)
{
    sf::Sprite objectSprite;
    texture_manager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setPosition(position);
    window.draw(objectSprite);
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
