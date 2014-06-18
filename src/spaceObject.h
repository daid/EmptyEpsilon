#ifndef SPACE_OBJECT_H
#define SPACE_OBJECT_H

#include "engine.h"
#include "mesh.h"

enum EDamageType
{
    DT_Energy,
    DT_Kinetic,
    DT_EMP
};

class SpaceObject;
extern PVector<SpaceObject> spaceObjectList;
class SpaceObject : public Collisionable, public MultiplayerObject
{
    float objectRadius;
public:
    SpaceObject(float collisionRange, string multiplayerName);
    
    float getRadius() { return objectRadius; }
    
    virtual void draw3D();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale);

    virtual bool hasShield() { return false; }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type) {}
};

class NebulaInfo
{
public:
    sf::Vector3f vector;
    std::string textureName;
};
extern std::vector<NebulaInfo> nebulaInfo;
void randomNebulas();

#endif//SPACE_OBJECT_H
