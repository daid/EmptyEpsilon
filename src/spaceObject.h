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
class PlayerSpaceship;
extern PVector<SpaceObject> space_object_list;
class SpaceObject : public Collisionable, public MultiplayerObject
{
    float object_radius;
public:
    int8_t faction_id;
    string comms_script_name;
    SpaceObject(float collisionRange, string multiplayerName);

    float getRadius() { return object_radius; }
    void setRadius(float radius) { object_radius = radius; setCollisionRadius(radius); }

    virtual void draw3D();
    virtual void draw3DTransparent() {}
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);

    virtual string getCallSign() { return "??? (" + string(getMultiplayerId()) + ")"; }
    virtual bool canBeTargeted() { return false; }
    virtual bool canBeTargetedByPlayer() { return canBeTargeted(); }
    virtual bool canBeDockedBy(P<SpaceObject> obj) { return false; }
    virtual bool hasShield() { return false; }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type) {}

    //virtual bool openCommChannel(P<PlayerSpaceship> ship) { return false; }
    //virtual void commChannelMessage(P<PlayerSpaceship> ship, int32_t message_id) {}

    static void damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, EDamageType type, float min_range);

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(unsigned int faction_id) { this->faction_id = faction_id; }
    unsigned int getFaction() { return faction_id; }
    void setCommsScript(string script_name) { this->comms_script_name = script_name; }
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
