#ifndef SPACE_OBJECT_H
#define SPACE_OBJECT_H

#include "engine.h"
#include "featureDefs.h"
#include "modelInfo.h"
#include "factionInfo.h"
#include "shipTemplate.h"

enum EDamageType
{
    DT_Energy,
    DT_Kinetic,
    DT_EMP
};

class DamageInfo
{
public:
    P<SpaceObject> instigator;
    EDamageType type;
    sf::Vector2f location;
    int frequency;
    ESystem system_target;
    
    DamageInfo()
    : instigator(), type(DT_Energy), location(0, 0), frequency(-1), system_target(SYS_None)
    {}

    DamageInfo(P<SpaceObject> instigator, EDamageType type, sf::Vector2f location)
    : instigator(instigator), type(type), location(location), frequency(-1), system_target(SYS_None)
    {}
};

class SpaceObject;
class PlayerSpaceship;
extern PVector<SpaceObject> space_object_list;
class SpaceObject : public Collisionable, public MultiplayerObject
{
    float object_radius;
    uint8_t faction_id;
    string object_description;
public:
    string comms_script_name;
    SpaceObject(float collisionRange, string multiplayerName, float multiplayer_significant_range=-1);

    float getRadius() { return object_radius; }
    void setRadius(float radius) { object_radius = radius; setCollisionRadius(radius); }
    
    string getDescription() { return object_description; }
    void setDescription(string description) { object_description = description; }

#if FEATURE_3D_RENDERING
    virtual void draw3D();
    virtual void draw3DTransparent() {}
#endif//FEATURE_3D_RENDERING
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void destroy();

    virtual string getCallSign() { return ""; }
    virtual bool canBeTargeted() { return false; }
    virtual bool canBeDockedBy(P<SpaceObject> obj) { return false; }
    virtual bool hasShield() { return false; }
    virtual bool canHideInNebula() { return true; }
    virtual bool canBeScanned() { return false; }
    virtual int scanningComplexity() { return 0; }
    virtual int scanningChannelDepth() { return 0; }
    virtual void scanned() { }
    virtual void takeDamage(float damage_amount, DamageInfo info) {}
    virtual std::unordered_map<string, string> getGMInfo() { return std::unordered_map<string, string>(); }
    virtual string getExportLine() { return ""; }

    static void damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, DamageInfo info, float min_range);

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(string faction_name) { this->faction_id = FactionInfo::findFactionId(faction_name); }
    string getFaction() { return factionInfo[this->faction_id]->getName(); }
    void setFactionId(unsigned int faction_id) { this->faction_id = faction_id; }
    unsigned int getFactionId() { return faction_id; }
    int getReputationPoints();
    bool takeReputationPoints(float amount);
    void removeReputationPoints(float amount);
    void addReputationPoints(float amount);
    void setCommsScript(string script_name) { this->comms_script_name = script_name; }
    bool areEnemiesInRange(float range);
    PVector<SpaceObject> getObjectsInRange(float range);
    string getSectorName();
    bool openCommsTo(P<PlayerSpaceship> target);
    bool sendCommsMessage(P<PlayerSpaceship> target, string message);

    ScriptCallback onDestroyed;

protected:
    ModelInfo model_info;
};

/* Define script conversion function for the DamageInfo structure. */
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di);

#endif//SPACE_OBJECT_H
