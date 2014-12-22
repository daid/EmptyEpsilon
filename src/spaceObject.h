#ifndef SPACE_OBJECT_H
#define SPACE_OBJECT_H

#include "engine.h"
#include "mesh.h"
#include "factionInfo.h"

enum EDamageType
{
    DT_Energy,
    DT_Kinetic,
    DT_EMP
};

class SpaceObject;
class PlayerSpaceship;
extern PVector<SpaceObject> space_object_list;
class SpaceObject : public Collisionable, public MultiplayerObject
{
    float object_radius;
public:
    uint8_t faction_id;
    string comms_script_name;
    SpaceObject(float collisionRange, string multiplayerName);

    float getRadius() { return object_radius; }
    void setRadius(float radius) { object_radius = radius; setCollisionRadius(radius); }

    virtual void draw3D();
    virtual void draw3DTransparent() {}
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);

    virtual string getCallSign() { return "??? (" + string(getMultiplayerId()) + ")"; }
    virtual bool canBeTargeted() { return false; }
    virtual bool canBeTargetedByPlayer() { return canBeTargeted(); }
    virtual bool canBeDockedBy(P<SpaceObject> obj) { return false; }
    virtual bool hasShield() { return false; }
    virtual bool hideInNebula() { return true; }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type, int frequency=-1) {}

    static void damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, EDamageType type, float min_range);

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(string faction_name) { this->faction_id = FactionInfo::findFactionId(faction_name); }
    void setFactionId(unsigned int faction_id) { this->faction_id = faction_id; }
    int getReputationPoints();
    bool takeReputationPoints(float amount);
    void addReputationPoints(float amount);
    unsigned int getFactionId() { return faction_id; }
    void setCommsScript(string script_name) { this->comms_script_name = script_name; }
    bool areEnemiesInRange(float range);
};

#endif//SPACE_OBJECT_H
