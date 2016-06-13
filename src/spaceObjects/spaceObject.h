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

class RawRadarSignatureInfo
{
public:
    float gravity;
    float electrical;
    float biological;

    RawRadarSignatureInfo()
    : gravity(0), electrical(0), biological(0) {}

    RawRadarSignatureInfo(float gravity, float electrical, float biological)
    : gravity(gravity), electrical(electrical), biological(biological) {}

    RawRadarSignatureInfo& operator+=(const RawRadarSignatureInfo& o)
    {
        gravity += o.gravity;
        electrical += o.electrical;
        biological += o.biological;
        return *this;
    }

    RawRadarSignatureInfo operator*(const float f) const
    {
        return RawRadarSignatureInfo(gravity * f, electrical * f, biological * f);
    }
};

enum EScannedState
{
    SS_NotScanned,
    SS_FriendOrFoeIdentified,
    SS_SimpleScan,
    SS_FullScan
};

class SpaceObject;
class PlayerSpaceship;
extern PVector<SpaceObject> space_object_list;
class SpaceObject : public Collisionable, public MultiplayerObject
{
    float object_radius;
    uint8_t faction_id;
    string object_description;

    /*!
     * Scan state per faction. Implementation wise, this vector is resized when a scan is done.
     * Index in the vector is the faction ID.
     * Which means the vector can be smaller then the number of factions available.
     * When the vector is smaller then the required faction ID, the scan state is SS_NotScanned
     */
    std::vector<EScannedState> scanned_by_faction;
public:
    string comms_script_name;
    ScriptSimpleCallback comms_script_callback;

    int scanning_complexity_value;
    int scanning_depth_value;
    string callsign;

    SpaceObject(float collisionRange, string multiplayerName, float multiplayer_significant_range=-1);

    float getRadius() { return object_radius; }
    void setRadius(float radius) { object_radius = radius; setCollisionRadius(radius); }

    string getDescription() { return object_description; }
    void setDescription(string description) { object_description = description; }

    float getHeading() { float ret = getRotation() - 270; while(ret < 0) ret += 360.0f; while(ret > 360.0f) ret -= 360.0f; return ret; }
    void setHeading(float heading) { setRotation(heading - 90); }

    virtual RawRadarSignatureInfo getRadarSignatureInfo() { return RawRadarSignatureInfo(0, 0, 0); }

#if FEATURE_3D_RENDERING
    virtual void draw3D();
    virtual void draw3DTransparent() {}
#endif//FEATURE_3D_RENDERING
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void destroy();

    virtual void setCallSign(string new_callsign) { callsign = new_callsign; }
    virtual string getCallSign() { return ""; }
    virtual bool canBeDockedBy(P<SpaceObject> obj) { return false; }
    virtual bool hasShield() { return false; }
    virtual bool canHideInNebula() { return true; }
    virtual bool canBeTargetedBy(P<SpaceObject> other);
    virtual bool canBeSelectedBy(P<SpaceObject> other);
    virtual bool canBeScannedBy(P<SpaceObject> other);
    virtual int scanningComplexity(P<SpaceObject> target) { return scanning_complexity_value; }
    virtual int scanningChannelDepth(P<SpaceObject> target) { return scanning_depth_value; }
    void setScanningParameters(int complexity, int depth);
    EScannedState getScannedStateFor(P<SpaceObject> other);
    void setScannedStateFor(P<SpaceObject> other, EScannedState state);
    EScannedState getScannedStateForFaction(int faction_id);
    void setScannedStateForFaction(int faction_id, EScannedState state);
    bool isScanned();
    bool isScannedBy(P<SpaceObject> obj);
    bool isScannedByFaction(string faction);
    void setScanned(bool scanned);
    void setScannedByFaction(string faction_name, bool scanned);
    virtual void scannedBy(P<SpaceObject> other);
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
    void setCommsScript(string script_name) { this->comms_script_name = script_name; this->comms_script_callback.clear(); }
    void setCommsFunction(ScriptSimpleCallback callback) { this->comms_script_name = ""; this->comms_script_callback = callback; }
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
