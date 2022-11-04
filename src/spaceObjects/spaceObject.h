#ifndef SPACE_OBJECT_H
#define SPACE_OBJECT_H

#include "multiplayer.h"
#include "scriptInterface.h"
#include "featureDefs.h"
#include "modelInfo.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "graphics/renderTarget.h"
#include "ecs/entity.h"
#include "components/radar.h"

#include <glm/mat4x4.hpp>

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
    glm::vec2 location{0, 0};
    int frequency;
    ESystem system_target;

    DamageInfo()
    : instigator(), type(DT_Energy), location(0, 0), frequency(-1), system_target(SYS_None)
    {}

    DamageInfo(P<SpaceObject> instigator, EDamageType type, glm::vec2 location)
    : instigator(instigator), type(type), location(location), frequency(-1), system_target(SYS_None)
    {}
};

enum EScannedState
{
    SS_NotScanned,
    SS_FriendOrFoeIdentified,
    SS_SimpleScan,
    SS_FullScan
};

/*! Radar rendering layer.
* Allow relative ordering of objects for drawing
*/
enum class ERadarLayer
{
    BackgroundZone,
    BackgroundObjects,
    Default
};

class SpaceObject;
class PlayerSpaceship;
extern PVector<SpaceObject> space_object_list;

class SpaceObject : public MultiplayerObject
{
    float object_radius;
    uint8_t faction_id;
    struct
    {
        string not_scanned;
        string friend_of_foe_identified;
        string simple_scan;
        string full_scan;
    } object_description;

    /*!
     * Scan state per faction. Implementation wise, this vector is resized when
     * a scan is done. The vector is indexed by faction ID, which means the
     * vector can be smaller than the number of available factions.
     * When the vector is smaller then the required faction ID, the scan state
     * is SS_NotScanned
     */
    std::vector<EScannedState> scanned_by_faction;
public:
    sp::ecs::Entity entity; //NOTE: On clients be careful, the Entity+components might be destroyed before the SpaceObject! Always check if this exists before using it.
    string comms_script_name;
    ScriptSimpleCallback comms_script_callback;

    int scanning_complexity_value;
    int scanning_depth_value;
    string callsign;

    SpaceObject(float collisionRange, string multiplayerName, float multiplayer_significant_range=-1);
    virtual ~SpaceObject();

    float getRadius() const { return object_radius; }
    void setRadius(float radius);

    bool hasWeight() { return has_weight; }

    void setRadarSignatureInfo(float grav, float elec, float bio) {
        if (entity) entity.addComponent<RawRadarSignatureInfo>(grav, elec, bio);
    }
    float getRadarSignatureGravity() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->gravity; }
    float getRadarSignatureElectrical() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->electrical; }
    float getRadarSignatureBiological() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->biological; }
    virtual ERadarLayer getRadarLayer() const { return ERadarLayer::Default; }

    string getDescription(EScannedState state)
    {
        switch(state)
        {
        case SS_NotScanned: return object_description.not_scanned;
        case SS_FriendOrFoeIdentified: return object_description.friend_of_foe_identified;
        case SS_SimpleScan: return object_description.simple_scan;
        case SS_FullScan: return object_description.full_scan;
        }
        return object_description.full_scan;
    }

    void setDescriptionForScanState(EScannedState state, string description)
    {
        switch(state)
        {
        case SS_NotScanned: object_description.not_scanned = description; break;
        case SS_FriendOrFoeIdentified: object_description.friend_of_foe_identified = description; break;
        case SS_SimpleScan: object_description.simple_scan = description; break;
        case SS_FullScan: object_description.full_scan = description; break;
        }
    }
    void setDescription(string description)
    {
        setDescriptions(description, description);
    }

    void setDescriptions(string unscanned_description, string scanned_description)
    {
        object_description.not_scanned = unscanned_description;
        object_description.friend_of_foe_identified = unscanned_description;
        object_description.simple_scan = scanned_description;
        object_description.full_scan = scanned_description;
    }

    string getDescriptionFor(P<SpaceObject> obj)
    {
        return getDescription(getScannedStateFor(obj));
    }

    float getHeading() { float ret = getRotation() - 270; while(ret < 0) ret += 360.0f; while(ret > 360.0f) ret -= 360.0f; return ret; }
    void setHeading(float heading) { setRotation(heading - 90); }

    void onDestroyed(ScriptSimpleCallback callback)
    {
        on_destroyed = callback;
    }

    virtual void draw3D();
    virtual void draw3DTransparent() {}
    virtual void drawOnRadar(sp::RenderTarget& window, glm::vec2 position, float scale, float rotation, bool longRange);
    virtual void drawOnGMRadar(sp::RenderTarget& window, glm::vec2 position, float scale, float rotation, bool longRange);
    virtual void destroy() override;

    virtual void setCallSign(string new_callsign) { callsign = new_callsign; }
    virtual string getCallSign() { return callsign; }
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
    virtual bool canBeHackedBy(P<SpaceObject> other);
    virtual std::vector<std::pair<ESystem, float> > getHackingTargets();
    virtual void hackFinished(P<SpaceObject> source, string target);
    virtual void takeDamage(float damage_amount, DamageInfo info) {}
    virtual std::unordered_map<string, string> getGMInfo() { return std::unordered_map<string, string>(); }
    virtual string getExportLine() { return ""; }

    static void damageArea(glm::vec2 position, float blast_range, float min_damage, float max_damage, DamageInfo info, float min_range);

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(string faction_name) { this->faction_id = FactionInfo::findFactionId(faction_name); }
    string getFaction() { if (factionInfo[faction_id]) return factionInfo[this->faction_id]->getName(); return ""; }
    string getLocaleFaction() { if (factionInfo[faction_id]) return factionInfo[this->faction_id]->getLocaleName(); return ""; }
    void setFactionId(unsigned int faction_id) { this->faction_id = faction_id; }
    unsigned int getFactionId() { return faction_id; }
    void setReputationPoints(float amount);
    int getReputationPoints();
    bool takeReputationPoints(float amount);
    void removeReputationPoints(float amount);
    void addReputationPoints(float amount);
    void setCommsScript(string script_name);
    void setCommsFunction(ScriptSimpleCallback callback) { this->comms_script_name = ""; this->comms_script_callback = callback; }
    bool areEnemiesInRange(float range);
    PVector<SpaceObject> getObjectsInRange(float range);
    string getSectorName();
    bool openCommsTo(P<PlayerSpaceship> target);
    bool sendCommsMessage(P<PlayerSpaceship> target, string message);
    bool sendCommsMessageNoLog(P<PlayerSpaceship> target, string message);

    //TODO
    virtual void collide(SpaceObject* other, float force) {}

    glm::vec2 getPosition() const;
    void setPosition(glm::vec2 p);
    float getRotation() const;
    void setRotation(float a);
    glm::vec2 getVelocity() const;
    float getAngularVelocity() const;

    ScriptSimpleCallback on_destroyed;

    glm::mat4 getModelTransform() const { return getModelMatrix(); }
protected:
    virtual glm::mat4 getModelMatrix() const;
    ModelInfo model_info;
    bool has_weight = true;
};

template<> void convert<EDamageType>::param(lua_State* L, int& idx, EDamageType& dt);
// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di);
// Function to convert a lua parameter to a scan state.
template<> void convert<EScannedState>::param(lua_State* L, int& idx, EScannedState& ss);

#endif//SPACE_OBJECT_H
