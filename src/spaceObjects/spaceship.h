#ifndef SPACESHIP_H
#define SPACESHIP_H
#include <i18n.h>

#include <array>
#include <optional>

#include "shipTemplateBasedObject.h"
#include "spaceStation.h"
#include "tween.h"
#include "components/docking.h"


enum EMainScreenSetting
{
    MSS_Front = 0,
    MSS_Back,
    MSS_Left,
    MSS_Right,
    MSS_Target,
    MSS_Tactical,
    MSS_LongRange
};
template<> void convert<EMainScreenSetting>::param(lua_State* L, int& idx, EMainScreenSetting& mss);

enum EMainScreenOverlay
{
    MSO_HideComms = 0,
    MSO_ShowComms
};
template<> void convert<EMainScreenOverlay>::param(lua_State* L, int& idx, EMainScreenOverlay& mso);

struct Speeds
{
    float forward;
    float reverse;
};
template<> int convert<Speeds>::returnType(lua_State* L, const Speeds &speeds);


class ShipSystemLegacy
{
public:
    static constexpr float power_factor_rate = 0.08f;
    static constexpr float default_heat_rate_per_second = 0.05f;
    static constexpr float default_power_rate_per_second = 0.3f;
    static constexpr float default_coolant_rate_per_second = 1.2f;
    float health; //1.0-0.0, where 0.0 is fully broken.
    float health_max; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float power_request;
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0
    float coolant_request;
    float hacked_level; //0.0-1.0
    float power_factor;
    float coolant_rate_per_second{};
    float heat_rate_per_second{};
    float power_rate_per_second{};

    float getHeatingDelta() const
    {
        return powf(1.7f, power_level - 1.0f) - (1.01f + coolant_level * 0.1f);
    }

    float getPowerUserFactor() const
    {
        return power_factor * power_factor_rate;
    }
};

class SpaceShip : public ShipTemplateBasedObject
{
public:
    constexpr static int max_frequency = 20;
    constexpr static float combat_maneuver_charge_time = 20.0f; /*< Amount of time it takes to fully charge the combat maneuver system */
    constexpr static float combat_maneuver_boost_max_time = 3.0f; /*< Amount of time we can boost with a fully charged combat maneuver system */
    constexpr static float combat_maneuver_strafe_max_time = 3.0f; /*< Amount of time we can strafe with a fully charged combat maneuver system */
    constexpr static float heat_per_combat_maneuver_boost = 0.2f;
    constexpr static float heat_per_combat_maneuver_strafe = 0.2f;
    constexpr static float unhack_time = 180.0f; //It takes this amount of time to go from 100% hacked to 0% hacked for systems.

    ShipSystemLegacy systems[SYS_COUNT];
    static std::array<float, SYS_COUNT> default_system_power_factors;
    /*!
     *[input] Ship will try to aim to this rotation. (degrees)
     */
    float target_rotation;

    /*!
     *[input] Ship will rotate in this velocity. ([-1,1], overrides target_rotation)
     */
    float turnSpeed;

    /*!
     * [config] Speed of rotation, in deg/second
     */
    float turn_speed;

    /*!
     * [output] How much charge there is in the combat maneuvering system (0.0-1.0)
     */
    float combat_maneuver_charge;
    /*!
     * [input] How much boost we want at this moment (0.0-1.0)
     */
    float combat_maneuver_boost_request;
    float combat_maneuver_boost_active;

    float combat_maneuver_strafe_request;
    float combat_maneuver_strafe_active;

    float combat_maneuver_boost_speed; /*< [config] Speed to indicate how fast we will fly forwards with a full boost */
    float combat_maneuver_strafe_speed; /*< [config] Speed to indicate how fast we will fly sideways with a full strafe */

    float wormhole_alpha;    //Used for displaying the Warp-postprocessor

    /// MultiplayerObjectID of the targeted object, or -1 when no target is selected.
    int32_t target_id;

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
    virtual float getShieldDamageFactor(DamageInfo& info, int shield_index) override;

    /*!
     * Check if the ship can be targeted.
     */
    virtual bool canBeTargetedBy(P<SpaceObject> other) override { return true; }

    /*!
     * didAnOffensiveAction is called whenever this ship does something offesive towards an other object
     * this can identify the ship as friend or foe.
     */
    void didAnOffensiveAction();

    /*!
     * Spaceship takes damage directly on hull.
     * This is used when shields are down or by weapons that ignore shields.
     * \param damage_amount Damage to be delt.
     * \param info Information about damage type (usefull for damage reduction, etc)
     */
    virtual void takeHullDamage(float damage_amount, DamageInfo& info) override;

    /*!
     * Spaceship is destroyed by damage.
     * \param info Information about damage type
     */
    virtual void destroyedByDamage(DamageInfo& info) override;

    virtual void collide(SpaceObject* other, float force) override;

    /// Function to use energy. Only player ships currently model energy use.
    bool useEnergy(float amount);

    /// Dummy virtual function to add heat on a system. The player ship class has an actual implementation of this as only player ships model heat right now.
    virtual void addHeat(ESystem system, float amount) {}

    virtual bool canBeScannedBy(P<SpaceObject> other) override { return getScannedStateFor(other) != SS_FullScan; }
    virtual int scanningComplexity(P<SpaceObject> other) override;
    virtual int scanningChannelDepth(P<SpaceObject> other) override;
    virtual void scannedBy(P<SpaceObject> other) override;
    void setScanState(EScannedState scanned);
    void setScanStateByFaction(string faction_name, EScannedState scanned);

    bool isFriendOrFoeIdentified();//[DEPRICATED]
    bool isFullyScanned();//[DEPRICATED]
    bool isFriendOrFoeIdentifiedBy(P<SpaceObject> other);
    bool isFullyScannedBy(P<SpaceObject> other);
    bool isFriendOrFoeIdentifiedByFaction(int faction_id);
    bool isFullyScannedByFaction(int faction_id);

    virtual bool canBeHackedBy(P<SpaceObject> other) override;
    virtual std::vector<std::pair<ESystem, float> > getHackingTargets() override;
    virtual void hackFinished(P<SpaceObject> source, string target) override;

    /*!
     * Check if ship has certain system
     */
    bool hasSystem(ESystem system);

    /*!
     * Check effectiveness of system.
     * If system has more / less power or is damages, this can influence the effectiveness.
     * \return float 0. to 1.
     */
    float getSystemEffectiveness(ESystem system);

    virtual void applyTemplateValues() override;

    P<SpaceObject> getTarget();

    virtual std::unordered_map<string, string> getGMInfo() override;

    bool isDocked(P<SpaceObject> target);
    P<SpaceObject> getDockedWith();
    DockingPort::State getDockingState();
    int getWeaponStorage(EMissileWeapons weapon) { return 0; } //TODO
    int getWeaponStorageMax(EMissileWeapons weapon) { return 0; } //TODO
    void setWeaponStorage(EMissileWeapons weapon, int amount) { } //TODO
    void setWeaponStorageMax(EMissileWeapons weapon, int amount) { } //TODO
    float getMaxEnergy();
    void setMaxEnergy(float amount);
    float getEnergy();
    void setEnergy(float amount);
    float getSystemHackedLevel(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].hacked_level; }
    void setSystemHackedLevel(ESystem system, float hacked_level) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].hacked_level = std::min(1.0f, std::max(0.0f, hacked_level)); }
    float getSystemHealth(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].health; }
    void setSystemHealth(ESystem system, float health) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].health = std::min(1.0f, std::max(-1.0f, health)); }
    float getSystemHealthMax(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].health_max; }
    void setSystemHealthMax(ESystem system, float health_max) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].health_max = std::min(1.0f, std::max(-1.0f, health_max)); }
    float getSystemHeat(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].heat_level; }
    void setSystemHeat(ESystem system, float heat) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].heat_level = std::min(1.0f, std::max(0.0f, heat)); }
    float getSystemHeatRate(ESystem system) const { if (system >= SYS_COUNT) return 0.f; if (system <= SYS_None) return 0.f; return systems[system].heat_rate_per_second; }
    void setSystemHeatRate(ESystem system, float rate) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].heat_rate_per_second = rate; }

    float getSystemPower(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].power_level; }
    void setSystemPower(ESystem system, float power) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].power_level = std::min(3.0f, std::max(0.0f, power)); }
    float getSystemPowerRate(ESystem system) const { if (system >= SYS_COUNT) return 0.f; if (system <= SYS_None) return 0.f; return systems[system].power_rate_per_second; }
    void setSystemPowerRate(ESystem system, float rate) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].power_rate_per_second = rate; }
    float getSystemPowerUserFactor(ESystem system) { if (system >= SYS_COUNT) return 0.f; if (system <= SYS_None) return 0.f; return systems[system].getPowerUserFactor(); }
    float getSystemPowerFactor(ESystem system) { if (system >= SYS_COUNT) return 0.f; if (system <= SYS_None) return 0.f; return systems[system].power_factor; }
    void setSystemPowerFactor(ESystem system, float factor) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].power_factor = factor; }
    float getSystemCoolant(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].coolant_level; }
    void setSystemCoolant(ESystem system, float coolant) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].coolant_level = std::min(1.0f, std::max(0.0f, coolant)); }
    Speeds getImpulseMaxSpeed();
    void setImpulseMaxSpeed(float forward_speed, std::optional<float> reverse_speed);
    float getSystemCoolantRate(ESystem system) const { if (system >= SYS_COUNT) return 0.f; if (system <= SYS_None) return 0.f; return systems[system].coolant_rate_per_second; }
    void setSystemCoolantRate(ESystem system, float rate) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].coolant_rate_per_second = rate; }
    float getRotationMaxSpeed() { return turn_speed; }
    void setRotationMaxSpeed(float speed) { turn_speed = speed; }
    Speeds getAcceleration();
    void setAcceleration(float acceleration, std::optional<float> reverse_acceleration);
    void setCombatManeuver(float boost, float strafe) { combat_maneuver_boost_speed = boost; combat_maneuver_strafe_speed = strafe; }
    bool hasJumpDrive() { return false; } //TODO
    void setJumpDrive(bool has_jump) {} //TODO
    void setJumpDriveRange(float min, float max) {} //TODO
    bool hasWarpDrive() { return false; } //TODO
    void setWarpDrive(bool has_warp) {} //TODO
    void setWarpSpeed(float speed) {} //TODO
    float getWarpSpeed() { return 1000.0f; } //TODO
    float getJumpDriveCharge() { return 0.0f; } //TODO
    void setJumpDriveCharge(float charge) {} //TODO
    float getJumpDelay() { return 0.0f; } //TODO

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

    int getShieldsFrequency() { return 0.0; } //TODO
    void setShieldsFrequency(int freq) { return; } //TODO

    int getBeamFrequency();

    void setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage);

    void setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate);

    void setBeamWeaponTexture(int index, string texture);

    void setBeamWeaponEnergyPerFire(int index, float energy);
    void setBeamWeaponHeatPerFire(int index, float heat);
    void setBeamWeaponArcColor(int index, float r, float g, float b, float fire_r, float fire_g, float fire_b);
    void setBeamWeaponDamageType(int index, EDamageType type);

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

    void addBroadcast(int threshold, string message);

    // Return a string that can be appended to an object create function in the lua scripting.
    // This function is used in getScriptExport calls to adjust for tweaks done in the GM screen.
    string getScriptExportModificationsOnTemplate();
    
};

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency);

string getMissileWeaponName(EMissileWeapons missile);
string getLocaleMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);
REGISTER_MULTIPLAYER_ENUM(EMainScreenOverlay);
REGISTER_MULTIPLAYER_ENUM(EScannedState);

string frequencyToString(int frequency);

#endif//SPACESHIP_H
