#include <SFML/OpenGL.hpp>
#include "spaceObject.h"
#include "factionInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS_NO_CREATE(SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFactionId);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFactionId);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsScript);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isEnemy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isFriendly);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getCallSign);
}

PVector<SpaceObject> space_object_list;

SpaceObject::SpaceObject(float collision_range, string multiplayer_name)
: Collisionable(collision_range), MultiplayerObject(multiplayer_name)
{
    object_radius = collision_range;
    space_object_list.push_back(this);
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
    return factionInfo[faction_id]->states[obj->faction_id] == FVF_Enemy;
}

bool SpaceObject::isFriendly(P<SpaceObject> obj)
{
    return factionInfo[faction_id]->states[obj->faction_id] == FVF_Friendly;
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
