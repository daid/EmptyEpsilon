#ifndef SPACESHIP_H
#define SPACESHIP_H
#include <i18n.h>

#include <array>
#include <optional>

#include "shipTemplateBasedObject.h"
#include "tween.h"
#include "components/docking.h"
#include "missileWeaponData.h"


class SpaceShip : public ShipTemplateBasedObject
{
public:
    SpaceShip(string multiplayerClassName, float multiplayer_significant_range=-1);
    virtual ~SpaceShip();

    virtual void draw3DTransparent() override;
    /*!
     * Get this ship's radar signature dynamically modified by the state of its
     * systems and current activity.
     */
    void updateDynamicRadarSignature();
    float getDynamicRadarSignatureGravity() { auto radar_signature = entity.getComponent<DynamicRadarSignatureInfo>(); if (!radar_signature) return getRadarSignatureGravity(); return radar_signature->gravity + getRadarSignatureGravity(); }
    float getDynamicRadarSignatureElectrical() { auto radar_signature = entity.getComponent<DynamicRadarSignatureInfo>(); if (!radar_signature) return getRadarSignatureElectrical(); return radar_signature->electrical + getRadarSignatureElectrical(); }
    float getDynamicRadarSignatureBiological() { auto radar_signature = entity.getComponent<DynamicRadarSignatureInfo>(); if (!radar_signature) return getRadarSignatureBiological(); return radar_signature->biological + getRadarSignatureBiological(); }

    /*!
     * Draw this ship on the radar.
     */
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual void update(float delta) override;

    /*!
     * Check if the ship can be targeted.
     */
    virtual bool canBeTargetedBy(sp::ecs::Entity other) override { return true; }

    virtual void collide(SpaceObject* other, float force) override;

    /// Function to use energy. Only player ships currently model energy use.
    bool useEnergy(float amount);

    virtual bool canBeScannedBy(sp::ecs::Entity other) override { return getScannedStateFor(other) != ScanState::State::FullScan; }
    void setScanState(ScanState::State scanned);
    void setScanStateByFaction(string faction_name, ScanState::State scanned);

    bool isFriendOrFoeIdentified();//[DEPRICATED]
    bool isFullyScanned();//[DEPRICATED]
    bool isFriendOrFoeIdentifiedBy(P<SpaceObject> other);
    bool isFullyScannedBy(P<SpaceObject> other);
    bool isFriendOrFoeIdentifiedByFaction(sp::ecs::Entity faction_entity);
    bool isFullyScannedByFaction(sp::ecs::Entity faction_entity);

    virtual void hackFinished(sp::ecs::Entity source, ShipSystem::Type target) override;

    /*!
     * Check if ship has certain system
     */
    bool hasSystem(ShipSystem::Type system);

    virtual void applyTemplateValues() override;

    P<SpaceObject> getTarget();

    bool isDocked(P<SpaceObject> target);
    P<SpaceObject> getDockedWith();
    DockingPort::State getDockingState();
    float getMaxEnergy();
    void setMaxEnergy(float amount);
    float getEnergy();
    void setEnergy(float amount);

    void setImpulseMaxSpeed(float forward_speed, std::optional<float> reverse_speed);
    void setAcceleration(float acceleration, std::optional<float> reverse_acceleration);

    float getBeamWeaponArc(int index);
    float getBeamWeaponDirection(int index);
    float getBeamWeaponRange(int index);

    float getBeamWeaponTurretArc(int index);

    float getBeamWeaponTurretDirection(int index);

    float getBeamWeaponTurretRotationRate(int index);

    float getBeamWeaponCycleTime(int index);
    float getBeamWeaponDamage(int index);
    float getBeamWeaponEnergyPerFire(int index);
    float getBeamWeaponHeatPerFire(int index);

    int getBeamFrequency();

    void setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage);

    void setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate);

    void setBeamWeaponTexture(int index, string texture);

    void setBeamWeaponEnergyPerFire(int index, float energy);
    void setBeamWeaponHeatPerFire(int index, float heat);
    void setBeamWeaponArcColor(int index, float r, float g, float b, float fire_r, float fire_g, float fire_b);
    void setBeamWeaponDamageType(int index, DamageType type);

    void setWeaponTubeCount(int amount);
    int getWeaponTubeCount();
    EMissileWeapons getWeaponTubeLoadType(int index);

    void weaponTubeAllowMissle(int index, EMissileWeapons type);
    void weaponTubeDisallowMissle(int index, EMissileWeapons type);
    void setWeaponTubeExclusiveFor(int index, EMissileWeapons type);
    void setWeaponTubeDirection(int index, float direction);
    void setTubeSize(int index, EMissileSizes size);
    EMissileSizes getTubeSize(int index);
    void setTubeLoadTime(int index, float time);
    float getTubeLoadTime(int index);

    void addBroadcast(FactionRelation threshold, string message);

    // Return a string that can be appended to an object create function in the lua scripting.
    // This function is used in getScriptExport calls to adjust for tweaks done in the GM screen.
    string getScriptExportModificationsOnTemplate();
    
};

#endif//SPACESHIP_H
