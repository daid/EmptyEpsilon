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
#include "components/shipsystem.h"
#include "components/name.h"
#include "components/scanning.h"
#include "systems/damage.h"

#include <glm/mat4x4.hpp>

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
    struct
    {
        string not_scanned;
        string friend_of_foe_identified;
        string simple_scan;
        string full_scan;
    } object_description;

public:
    sp::ecs::Entity entity; //NOTE: On clients be careful, the Entity+components might be destroyed before the SpaceObject! Always check if this exists before using it.

    SpaceObject(float collisionRange, string multiplayerName, float multiplayer_significant_range=-1);
    virtual ~SpaceObject();

    bool hasWeight() { return has_weight; }

    void setRadarSignatureInfo(float grav, float elec, float bio) {
        if (entity) entity.addComponent<RawRadarSignatureInfo>(grav, elec, bio);
    }
    float getRadarSignatureGravity() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->gravity; }
    float getRadarSignatureElectrical() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->electrical; }
    float getRadarSignatureBiological() { auto radar_signature = entity.getComponent<RawRadarSignatureInfo>(); if (!radar_signature) return 0.0; return radar_signature->biological; }
    virtual ERadarLayer getRadarLayer() const { return ERadarLayer::Default; }

    string getDescription(ScanState::State state)
    {
        switch(state)
        {
        case ScanState::State::NotScanned: return object_description.not_scanned;
        case ScanState::State::FriendOrFoeIdentified: return object_description.friend_of_foe_identified;
        case ScanState::State::SimpleScan: return object_description.simple_scan;
        case ScanState::State::FullScan: return object_description.full_scan;
        }
        return object_description.full_scan;
    }

    void setDescriptionForScanState(ScanState::State state, string description)
    {
        switch(state)
        {
        case ScanState::State::NotScanned: object_description.not_scanned = description; break;
        case ScanState::State::FriendOrFoeIdentified: object_description.friend_of_foe_identified = description; break;
        case ScanState::State::SimpleScan: object_description.simple_scan = description; break;
        case ScanState::State::FullScan: object_description.full_scan = description; break;
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

    string getDescriptionFor(sp::ecs::Entity other)
    {
        return getDescription(getScannedStateFor(other));
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

    virtual void setCallSign(string new_callsign) { entity.getOrAddComponent<CallSign>().callsign = new_callsign; }
    virtual string getCallSign() { auto cs = entity.getComponent<CallSign>(); if (cs) return cs->callsign; return ""; }
    virtual bool hasShield() { return false; }
    virtual bool canHideInNebula() { return true; }
    virtual bool canBeTargetedBy(sp::ecs::Entity other);
    virtual bool canBeSelectedBy(sp::ecs::Entity other);
    virtual bool canBeScannedBy(sp::ecs::Entity other);
    virtual int scanningComplexity(P<SpaceObject> target) { return -1; } //TODO
    virtual int scanningChannelDepth(P<SpaceObject> target) { return -1; } //TODO
    void setScanningParameters(int complexity, int depth);
    ScanState::State getScannedStateFor(sp::ecs::Entity other);
    void setScannedStateFor(P<SpaceObject> other, ScanState::State state);
    ScanState::State getScannedStateForFaction(sp::ecs::Entity faction);
    void setScannedStateForFaction(sp::ecs::Entity faction, ScanState::State state);
    bool isScanned();
    bool isScannedBy(P<SpaceObject> obj);
    bool isScannedByFaction(string faction);
    void setScanned(bool scanned);
    void setScannedByFaction(string faction_name, bool scanned);
    virtual void hackFinished(P<SpaceObject> source, ShipSystem::Type target);
    void takeDamage(float damage_amount, DamageInfo info) { DamageSystem::applyDamage(entity, damage_amount, info); }
    virtual std::unordered_map<string, string> getGMInfo() { return std::unordered_map<string, string>(); }
    virtual string getExportLine() { return ""; }

    bool isEnemy(P<SpaceObject> obj);
    bool isFriendly(P<SpaceObject> obj);
    void setFaction(string faction_name);
    string getFaction() { return Faction::getInfo(entity).name; }
    string getLocaleFaction() { return Faction::getInfo(entity).locale_name; }
    void setFactionId(sp::ecs::Entity faction_id) { entity.addComponent<Faction>(faction_id); }
    sp::ecs::Entity getFactionId() { auto f = entity.getComponent<Faction>(); if (f) return f->entity; return {}; }
    void setReputationPoints(float amount);
    int getReputationPoints();
    bool takeReputationPoints(float amount);
    void removeReputationPoints(float amount);
    void addReputationPoints(float amount);
    void setCommsScript(string script_name);
    void setCommsFunction(ScriptSimpleCallback callback) { } //TODO
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

template<> void convert<DamageType>::param(lua_State* L, int& idx, DamageType& dt);
// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di);
// Function to convert a lua parameter to a scan state.
template<> void convert<ScanState::State>::param(lua_State* L, int& idx, ScanState::State& ss);

#endif//SPACE_OBJECT_H
