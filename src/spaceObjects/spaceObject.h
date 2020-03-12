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

// Radar signature data, used by rawScannerDataOverlay.
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

    bool operator!=(const RawRadarSignatureInfo& o)
    {
        return gravity != o.gravity || electrical != o.electrical || biological != o.biological;
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
    struct
    {
        string not_scanned;
        string friend_of_foe_identified;
        string simple_scan;
        string full_scan;
    } object_description;
    RawRadarSignatureInfo radar_signature;
    bool is_visible;

    /*!
     * Scan state per faction. Implementation wise, this vector is resized when
     * a scan is done. The vector is indexed by faction ID, which means the
     * vector can be smaller than the number of available factions.
     * When the vector is smaller then the required faction ID, the scan state
     * is SS_NotScanned
     */
    std::vector<EScannedState> scanned_by_faction;
public:
    string comms_script_name;
    ScriptSimpleCallback comms_script_callback;

    int scanning_complexity_value;
    int scanning_depth_value;
    string callsign;

    SpaceObject(float collisionRange, string multiplayerName, float multiplayer_significant_range=-1);
    virtual ~SpaceObject();

    float getRadius() { return object_radius; }
    void setRadius(float radius) { object_radius = radius; setCollisionRadius(radius); }

    // Return the object's raw radar signature. The default signature is 0 grav, 0 elec, 0 bio.
    virtual RawRadarSignatureInfo getRadarSignatureInfo() { return radar_signature; }
    void setRadarSignatureInfo(float grav, float elec, float bio) { radar_signature = RawRadarSignatureInfo(grav, elec, bio); }
    void setRadarSignatureGravity(float grav) { radar_signature.gravity = grav; }
    float getRadarSignatureGravity() { return radar_signature.gravity; }
    void setRadarSignatureElectrical(float elec) { radar_signature.electrical = elec; }
    float getRadarSignatureElectrical() { return radar_signature.electrical; }
    void setRadarSignatureBiological(float bio) { radar_signature.biological = bio; }
    float getRadarSignatureBiological() { return radar_signature.biological; }

    // Return the object's radar visibility.
    void setVisibility(bool visibility) { is_visible = visibility; }
    bool isVisible() { return is_visible; }
    virtual bool reachesSignalThreshold(float signal_threshold);

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

#if FEATURE_3D_RENDERING
    virtual void draw3D();
    virtual void draw3DTransparent() {}
#endif//FEATURE_3D_RENDERING
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void destroy();

    virtual void setCallSign(string new_callsign) { callsign = new_callsign; }
    virtual string getCallSign() { return callsign; }
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
    virtual bool canBeHackedBy(P<SpaceObject> other);
    virtual std::vector<std::pair<string, float> > getHackingTargets();
    virtual void hackFinished(P<SpaceObject> source, string target);
    virtual void takeDamage(float damage_amount, DamageInfo info) {}
    virtual std::unordered_map<string, string> getGMInfo() { return std::unordered_map<string, string>(); }
    virtual string getExportLine() { return ""; }

    static void damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, DamageInfo info, float min_range);

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(string faction_name) { this->faction_id = FactionInfo::findFactionId(faction_name); }
    string getFaction() { return factionInfo[this->faction_id]->getName(); }
    string getLocaleFaction() { return factionInfo[this->faction_id]->getLocaleName(); }
    void setFactionId(unsigned int faction_id) { this->faction_id = faction_id; }
    unsigned int getFactionId() { return faction_id; }
    void setReputationPoints(float amount);
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

// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di);
// Function to convert a lua parameter to a scan state.
template<> void convert<EScannedState>::param(lua_State* L, int& idx, EScannedState& ss);

#endif//SPACE_OBJECT_H
