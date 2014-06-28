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
    int8_t factionId;
    SpaceObject(float collisionRange, string multiplayerName);
    
    float getRadius() { return objectRadius; }
    void setRadius(float radius) { objectRadius = radius; setCollisionRadius(radius); }
    
    virtual void draw3D();
    virtual void draw3DTransparent() {}
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);

    virtual bool canBeTargeted() { return false; }
    virtual bool hasShield() { return false; }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type) {}
    
    static void damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, EDamageType type, float min_range);
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
