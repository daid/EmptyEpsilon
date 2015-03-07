#include <SFML/OpenGL.hpp>
#include "spaceObject.h"
#include "factionInfo.h"
#include "gameGlobalInfo.h"

#include "scriptInterface.h"
/// The SpaceObject is the base for every object which can be seen in space.
/// General properties can read and set for each object. Each object has a position, rotation and collision shape.
REGISTER_SCRIPT_CLASS_NO_CREATE(SpaceObject)
{
    /// Set the position of this object in 2D space, in meters
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setPosition);
    /// Sets the absolute rotation of this object. In degrees.
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setRotation);
    /// Gets the position of this object, returns x, y
    /// Example: local x, y = obj:getPosition()
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getPosition);
    /// Gets the rotation of this object. In degrees.
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getRotation);
    /// Gets the velocity of the object, in 2D space, in meters/second
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getVelocity);
    /// Gets the rotational velocity of the object, in degree/second
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getAngularVelocity);
    /// Sets the velocity of the object, in 2D space, in meters/second
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setVelocity);
    /// Sets the rotational velocity of the object, in degree/second
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setAngularVelocity);
    
    /// Sets the faction to which this object belongs. Requires a string as input.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFaction);
    /// Sets the faction to which this object belongs. Requires a index in the faction list.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFactionId);
    /// Gets the index in the faction list from this object.
    /// Can be used in combination with setFactionId to make sure two objects have the same faction.
    /// Example: other:setFactionId(obj:getFactionId())
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFactionId);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsScript);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isEnemy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isFriendly);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getCallSign);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, areEnemiesInRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getObjectsInRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getReputationPoints);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, takeReputationPoints);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, addReputationPoints);
}

PVector<SpaceObject> space_object_list;

SpaceObject::SpaceObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: Collisionable(collision_range), MultiplayerObject(multiplayer_name)
{
    object_radius = collision_range;
    space_object_list.push_back(this);
    faction_id = 0;

    registerMemberReplication(&faction_id);
    registerCollisionableReplication(multiplayer_significant_range);
}

void SpaceObject::draw3D()
{
}

void SpaceObject::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange)
{
}

void SpaceObject::destroy()
{
    onDestroyed();
    MultiplayerObject::destroy();
}

bool SpaceObject::isEnemy(P<SpaceObject> obj)
{
    return factionInfo[faction_id]->states[obj->faction_id] == FVF_Enemy;
}

bool SpaceObject::isFriendly(P<SpaceObject> obj)
{
    return factionInfo[faction_id]->states[obj->faction_id] == FVF_Friendly;
}

void SpaceObject::damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, DamageInfo& info, float min_range)
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(position - sf::Vector2f(blast_range, blast_range), position + sf::Vector2f(blast_range, blast_range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj)
        {
            float dist = sf::length(position - obj->getPosition()) - obj->getRadius() - min_range;
            if (dist < 0) dist = 0;
            if (dist < blast_range - min_range)
            {
                obj->takeDamage(max_damage - (max_damage - min_damage) * dist / (blast_range - min_range), info);
            }
        }
    }
}

bool SpaceObject::areEnemiesInRange(float range)
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(range, range), getPosition() + sf::Vector2f(range, range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj && isEnemy(obj))
        {
            if (getPosition() - obj->getPosition() < range + obj->getRadius())
                return true;
        }
    }
    return false;
}

PVector<SpaceObject> SpaceObject::getObjectsInRange(float range)
{
    PVector<SpaceObject> ret;
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(range, range), getPosition() + sf::Vector2f(range, range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj && getPosition() - obj->getPosition() < range + obj->getRadius())
        {
            ret.push_back(obj);
        }
    }
    return ret;
}

int SpaceObject::getReputationPoints()
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return 0;
    return gameGlobalInfo->reputation_points[faction_id];
}

bool SpaceObject::takeReputationPoints(float amount)
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return false;
     if (gameGlobalInfo->reputation_points[faction_id] < amount)
        return false;
    gameGlobalInfo->reputation_points[faction_id] -= amount;
    return true;
}

void SpaceObject::addReputationPoints(float amount)
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return;
    gameGlobalInfo->reputation_points[faction_id] += amount;
}
