#include <SFML/OpenGL.hpp>
#include "spaceObject.h"
#include "factionInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS_NO_CREATE(SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsScript);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isEnemy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isFriendly);
}

PVector<SpaceObject> spaceObjectList;

SpaceObject::SpaceObject(float collisionRange, string multiplayerName)
: Collisionable(collisionRange), MultiplayerObject(multiplayerName)
{
    objectRadius = collisionRange;
    spaceObjectList.push_back(this);
    faction_id = 0;
    
    registerMemberReplication(&faction_id);
    registerCollisionableReplication();
}

void SpaceObject::draw3D()
{
}

void SpaceObject::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange)
{
}

bool SpaceObject::isEnemy(P<SpaceObject> obj)
{
    return factionInfo[faction_id].states[obj->faction_id] == FVF_Enemy;
}

bool SpaceObject::isFriendly(P<SpaceObject> obj)
{
    return factionInfo[faction_id].states[obj->faction_id] == FVF_Friendly;
}

void SpaceObject::damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, EDamageType type, float min_range)
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(position - sf::Vector2f(blast_range, blast_range), position + sf::Vector2f(blast_range, blast_range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj)
        {
            float dist = sf::length(position - obj->getPosition()) - obj->getRadius() - min_range;
            if (dist < 0) dist = 0;
            if (dist < blast_range)
            {
                obj->takeDamage(max_damage - (max_damage - min_damage) * dist / blast_range, position, type);
            }
        }
    }
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
