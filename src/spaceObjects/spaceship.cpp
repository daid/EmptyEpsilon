#include "spaceship.h"

#include <array>

#include <i18n.h>

#include "mesh.h"
#include "random.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/beamEffect.h"
#include "factionInfo.h"
#include "spaceObjects/explosionEffect.h"
#include "particleEffect.h"
#include "spaceObjects/warpJammer.h"
#include "textureManager.h"
#include "multiplayer_client.h"
#include "gameGlobalInfo.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/shields.h"
#include "components/hull.h"
#include "components/missiletubes.h"

#include "scriptInterface.h"

#include <SDL_assert.h>

REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceShip, ShipTemplateBasedObject)
{
    /// [DEPRECATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentified);
    /// [DEPRECATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScanned);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockedWith);
    //REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDockingState);
    /// Returns gets this ship target.
    /// For example enemy targetted by player ship's weapons.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getShieldsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShieldsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getMaxEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setMaxEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasSystem);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHackedLevel);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHackedLevel);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealthMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealthMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeatRate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeatRate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPowerRate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerRate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPowerFactor);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPowerFactor);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolant);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolant);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolantRate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolantRate);
    ///Get multiple results, first one is forward speed and second one is reverse speed.
    ///ex : forward,reverse = getImpulseMaxSpeed() (you can also use select or _ to get only reverse speed)
    ///You can also only get forward speed, reverse speed will just be discarded : 
    ///forward = getImpulseMaxSpeed()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getImpulseMaxSpeed);
    ///Sets max speed.
    ///If called with only one argument, sets forward and reverse speed to equal values.
    ///If called with two arguments, first one is forward speed and second one is reverse speed.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setImpulseMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getRotationMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRotationMaxSpeed);
    ///Get multiple resulsts, first one is forward acceleration and second one is reverse acceleration.
    ///ex : forward, reverse = getAcceleration (you can also use select or _ to get only reverse speed)
    ///You can also only get forward speed, reverse speed will just be discarded : 
    ///forward = getAcceleration()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getAcceleration);
    ///Sets acceleration.
    ///If called with one argument, sets forward and reverse acceleration to equal values.
    ///If called with two arguments, first one is forward acceleration and second one is reverse acceleration.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setAcceleration);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setCombatManeuver);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDriveRange);
    /// sets the current jump range charged.
    /// ships will be able to jump when this is equal to their max jump drive range.
    /// Example ship:setJumpDriveCharge(50000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDriveCharge);
    /// returns the current amount of jump charged.
    /// Example ship:getJumpDriveCharge()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getJumpDriveCharge);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getJumpDelay);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasWarpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpDrive);
    /// Set the warp speed for this ship's warp level 1.
    /// Setting this is equivalent to also setting setWarpDrive(true).
    /// If a value isn't specified in the ship template, the default is 1000.
    /// Requires a numeric value.
    /// Example: ship:setWarpSpeed(500);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWarpSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponCycleTime);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDamage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponEnergyPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponHeatPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeapon);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTurret);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponEnergyPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponHeatPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponArcColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponDamageType);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeLoadType);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeAllowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeDisallowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeExclusiveFor);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeDirection);
    /// Set the tube size
    /// Example: ship:setTubeSize(0,"small")
    /// Valid Sizes: "small" "medium" "large"
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setTubeSize);
    /// Returns the size of the tube
    /// Example: local size = ship:getTubeSize(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTubeSize);
    // Returns the time for a tube load
    // Example: load_time = ship:getTubeLoadTime(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTubeLoadTime);
    // Sets the load time for a tube
    // Example ship:setTubeLoadTime(0, 15)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setTubeLoadTime);
    /// Get the dynamic radar signature values for each component band.
    /// Returns a float.
    /// Example: obj:getDynamicRadarSignatureGravity()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureGravity);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureElectrical);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getDynamicRadarSignatureBiological);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, addBroadcast);
    /// Set the scan state of this ship for every faction.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanState);
    /// Set the scane state of this ship for a particular faction.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanStateByFaction);
}

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    wormhole_alpha = 0.f;
    target_id = -1;

    registerMemberReplication(&wormhole_alpha, 0.5f);
    registerMemberReplication(&target_id);

    scanning_complexity_value = -1;
    scanning_depth_value = -1;

    // Ships can have dynamic signatures. Initialize a default baseline value
    // from which clients derive the dynamic signature on update.
    setRadarSignatureInfo(0.05f, 0.2f, 0.2f);

    if (game_server)
        setCallSign(gameGlobalInfo->getNextShipCallsign());

    if (entity) {
        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.flags |= RadarTrace::ArrowIfNotScanned;

        auto shields = entity.getComponent<Shields>();
        if (shields)
            shields->frequency = irandom(0, max_frequency);
    }
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
SpaceShip::~SpaceShip()
{
}

void SpaceShip::applyTemplateValues()
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (ship_template->beams[n].getRange() > 0.0f) {
            auto& beamweaponsystem = entity.getOrAddComponent<BeamWeaponSys>();
            auto& mount = beamweaponsystem.mounts[n];
            mount.position = ship_template->model_data->getBeamPosition(n);
            mount.arc = ship_template->beams[n].getArc();
            mount.direction = ship_template->beams[n].getDirection();
            mount.range = ship_template->beams[n].getRange();
            mount.turret_arc = ship_template->beams[n].getTurretArc();
            mount.turret_direction = ship_template->beams[n].getTurretDirection();
            mount.turret_rotation_rate = ship_template->beams[n].getTurretRotationRate();
            mount.cycle_time = ship_template->beams[n].getCycleTime();
            mount.damage = ship_template->beams[n].getDamage();
            mount.texture = ship_template->beams[n].getBeamTexture();
            mount.energy_per_beam_fire = ship_template->beams[n].getEnergyPerFire();
            mount.heat_per_beam_fire = ship_template->beams[n].getHeatPerFire();
        }
    }

    if (ship_template->energy_storage_amount) {
        auto& reactor = entity.getOrAddComponent<Reactor>();
        reactor.energy = reactor.max_energy = ship_template->energy_storage_amount;
    }
    

    if (ship_template->impulse_speed) {
        auto& engine = entity.getOrAddComponent<ImpulseEngine>();
        engine.max_speed_forward = ship_template->impulse_speed;
        engine.max_speed_reverse = ship_template->impulse_reverse_speed;
        engine.acceleration_forward = ship_template->impulse_acceleration;
        engine.acceleration_reverse = ship_template->impulse_reverse_acceleration;
        engine.sound = ship_template->impulse_sound_file;
    }
    
    if (ship_template->turn_speed) {
        auto& thrusters = entity.getOrAddComponent<ManeuveringThrusters>();
        thrusters.speed = ship_template->turn_speed;
    }
    if (ship_template->combat_maneuver_boost_speed || ship_template->combat_maneuver_strafe_speed) {
        auto& thrusters = entity.getOrAddComponent<CombatManeuveringThrusters>();
        thrusters.boost.speed = ship_template->combat_maneuver_boost_speed;
        thrusters.strafe.speed = ship_template->combat_maneuver_strafe_speed;
    }

    if (ship_template->warp_speed > 0.0f) {
        auto& warp = entity.getOrAddComponent<WarpDrive>();
        warp.speed_per_level = ship_template->warp_speed;
    }
    if (ship_template->has_jump_drive) {
        auto& jump = entity.getOrAddComponent<JumpDrive>();
        jump.min_distance = ship_template->jump_drive_min_distance;
        jump.max_distance = ship_template->jump_drive_max_distance;
    }
    if (ship_template->weapon_tube_count) {
        auto& tubes = entity.getOrAddComponent<MissileTubes>();
        tubes.count = ship_template->weapon_tube_count;
        for(int n=0; n<ship_template->weapon_tube_count; n++)
        {
            auto& tube = tubes.mounts[n];
            tube.load_time = ship_template->weapon_tube[n].load_time;
            tube.direction = ship_template->weapon_tube[n].direction;
            tube.size = ship_template->weapon_tube[n].size;
            tube.type_allowed_mask = ship_template->weapon_tube[n].type_allowed_mask;
        }
        for(int n=0; n<MW_Count; n++)
            tubes.storage[n] = tubes.storage_max[n] = ship_template->weapon_storage[n];
    }

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);
}

void SpaceShip::draw3DTransparent()
{
    if (!ship_template) return;
    ShipTemplateBasedObject::draw3DTransparent();

    auto jump = entity.getComponent<JumpDrive>();
    if ((jump && jump->delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump ? jump->delay : 0.0f;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(getModelMatrix(), textureManager.getTexture("texture/electric_sphere_texture.png"), alpha);
    }
}

void SpaceShip::updateDynamicRadarSignature()
{
    // Adjust radar_signature dynamically based on current state and activity.
    // radar_signature becomes the ship's baseline radar signature.
    DynamicRadarSignatureInfo signature_delta;

    // For each ship system ...
    for(int n = 0; n < ShipSystem::COUNT; n++)
    {
        auto ship_system = static_cast<ShipSystem::Type>(n);

        // ... increase the biological band based on system heat, offset by
        // coolant.
        signature_delta.biological += std::max(
            0.0f,
            std::min(
                1.0f,
                getSystemHeat(ship_system) - (getSystemCoolant(ship_system) / 10.0f)
            )
        );

        // ... adjust the electrical band if system power allocation is not 100%.
        if (ship_system == ShipSystem::Type::JumpDrive)
        {
            auto jump = entity.getComponent<JumpDrive>();
            if (jump && jump->charge < jump->max_distance) {
                // ... elevate electrical after a jump, since recharging jump consumes energy.
                signature_delta.electrical += std::clamp(getSystemPower(ship_system) * (jump->charge + 0.01f / jump->max_distance), 0.0f, 1.0f);
            }
        } else if (getSystemPower(ship_system) != 1.0f)
        {
            // For non-Jump systems, allow underpowered systems to reduce the
            // total electrical signal output.
            signature_delta.electrical += std::max(
                -1.0f,
                std::min(
                    1.0f,
                    getSystemPower(ship_system) - 1.0f
                )
            );
        }
    }

    // Increase the gravitational band if the ship is about to jump, or is
    // actively warping.
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
    {
        signature_delta.gravity += std::clamp((1.0f / jump->delay + 0.01f) + 0.25f, 0.0f, 1.0f);
    }
    auto warp = entity.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f)
    {
        signature_delta.gravity += warp->current;
    }

    // Update the signature by adding the delta to its baseline.
    if (entity)
        entity.addComponent<DynamicRadarSignatureInfo>(signature_delta);
}

void SpaceShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    model_info.engine_scale = 0.0f;
    auto thrusters = entity.getComponent<ManeuveringThrusters>();
    if (thrusters) model_info.engine_scale = std::abs(getAngularVelocity() / thrusters->speed);
    auto impulse = entity.getComponent<ImpulseEngine>();
    if (impulse)
        model_info.engine_scale = std::max(model_info.engine_scale, std::abs(impulse->actual));
    model_info.engine_scale = std::min(1.0f, model_info.engine_scale);

    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
        model_info.warp_scale = (10.0f - jump->delay) / 10.0f;
    else
        model_info.warp_scale = 0.f;
    
    updateDynamicRadarSignature();
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (game_server)
        return game_server->getObjectById(target_id);
    return game_client->getObjectById(target_id);
}

void SpaceShip::collide(SpaceObject* other, float force)
{
}

bool SpaceShip::useEnergy(float amount)
{
    // Try to consume an amount of energy. If it works, return true.
    // If it doesn't, return false.
    auto reactor = entity.getComponent<Reactor>();
    if (reactor)
        return reactor->useEnergy(amount);
    return true;
}


int SpaceShip::scanningComplexity(P<SpaceObject> other)
{
    if (scanning_complexity_value > -1)
        return scanning_complexity_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 2;
        return 1;
    case SC_Advanced:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 3;
        return 2;
    }
    return 0;
}

int SpaceShip::scanningChannelDepth(P<SpaceObject> other)
{
    if (scanning_depth_value > -1)
        return scanning_depth_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        return 2;
    case SC_Advanced:
        return 2;
    }
    return 0;
}

void SpaceShip::scannedBy(P<SpaceObject> other)
{
    switch(getScannedStateFor(other))
    {
    case SS_NotScanned:
    case SS_FriendOrFoeIdentified:
        setScannedStateFor(other, SS_SimpleScan);
        break;
    case SS_SimpleScan:
        setScannedStateFor(other, SS_FullScan);
        break;
    case SS_FullScan:
        break;
    }
}

void SpaceShip::setScanState(EScannedState state)
{
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        setScannedStateForFaction(faction_id, state);
    }
}

void SpaceShip::setScanStateByFaction(string faction_name, EScannedState state)
{
    setScannedStateForFaction(FactionInfo::findFactionId(faction_name), state);
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Deprecated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) > SS_NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Deprecated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) >= SS_FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FullScan;
}

bool SpaceShip::canBeHackedBy(P<SpaceObject> other)
{
    return (!(this->isFriendly(other)) && this->isFriendOrFoeIdentifiedBy(other)) ;
}

std::vector<std::pair<ShipSystem::Type, float>> SpaceShip::getHackingTargets()
{
    std::vector<std::pair<ShipSystem::Type, float>> results;
    for(unsigned int n=0; n<ShipSystem::COUNT; n++)
    {
        if (ShipSystem::Type(n) == ShipSystem::Type::Reactor) continue;
        auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
        if (sys)
            results.emplace_back(ShipSystem::Type(n), sys->hacked_level);
    }
    return results;
}

void SpaceShip::hackFinished(P<SpaceObject> source, ShipSystem::Type target)
{
    auto sys = ShipSystem::get(entity, target);
    if (sys)
        sys->hacked_level = std::min(1.0f, sys->hacked_level + 0.5f);
}

float SpaceShip::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    auto shields = entity.getComponent<Shields>();
    if (!shields)
        return 1.0f;

    float frequency_damage_factor = 1.f;
    if (info.type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
    {
        frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shields->frequency);
    }
    auto system = shields->getSystemForIndex(shield_index);

    //Shield damage reduction curve. Damage reduction gets slightly exponetial effective with power.
    // This also greatly reduces the ineffectiveness at low power situations.
    float shield_damage_exponent = 1.6f;
    float shield_damage_divider = 7.0f;
    float shield_damage_factor = 1.0f + powf(1.0f, shield_damage_exponent) / shield_damage_divider-powf(system.getSystemEffectiveness(), shield_damage_exponent) / shield_damage_divider;

    return shield_damage_factor * frequency_damage_factor;
}

void SpaceShip::didAnOffensiveAction()
{
    //We did an offensive action towards our target.
    // Check for each faction. If this faction knows if the target is an enemy or a friendly, it now knows if this object is an enemy or a friendly.
    for(unsigned int faction_id=0; faction_id<factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) == SS_NotScanned)
        {
            if (getTarget() && getTarget()->getScannedStateForFaction(faction_id) != SS_NotScanned)
                setScannedStateForFaction(faction_id, SS_FriendOrFoeIdentified);
        }
    }
}

void SpaceShip::takeHullDamage(float damage_amount, DamageInfo& info)
{
    auto hull = entity.getComponent<Hull>();
    if (gameGlobalInfo->use_system_damage && hull)
    {
        if (auto sys = ShipSystem::get(entity, info.system_target))
        {
            //Target specific system
            float system_damage = (damage_amount / hull->max) * 2.0f;
            if (info.type == DT_Energy)
                system_damage *= 3.0f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            sys->health -= system_damage;
            if (sys->health < -1.0f)
                sys->health = -1.0f;

            for(int n=0; n<2; n++)
            {
                auto random_system = ShipSystem::Type(irandom(0, ShipSystem::COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull->max) * 1.0f;
                sys = ShipSystem::get(entity, random_system);
                if (sys) {
                    sys->health -= system_damage;
                    if (sys->health < -1.0f)
                        sys->health = -1.0f;
                }
            }

            if (info.type == DT_Energy)
                damage_amount *= 0.02f;
            else
                damage_amount *= 0.5f;
        }else{
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (damage_amount / hull->max) * 3.0f;
            if (info.type == DT_Energy)
                system_damage *= 2.5f;   //Beam weapons do more system damage, as they penetrate the hull easier.

            auto random_system = ShipSystem::Type(irandom(0, ShipSystem::COUNT - 1));
            sys = ShipSystem::get(entity, random_system);
            if (sys) {
                sys->health -= system_damage;
                if (sys->health < -1.0f)
                    sys->health = -1.0f;
            }
        }
    }

    ShipTemplateBasedObject::takeHullDamage(damage_amount, info);
}

void SpaceShip::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius() * 1.5f);
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.f, 0.2f, 0.2f);

    if (info.instigator)
    {
        float points = 0.0f;
        auto hull = entity.getComponent<Hull>();
        if (hull)
            points += hull->max * 0.1f;

        auto shields = entity.getComponent<Shields>();
        if (shields)
        {
            for(int n=0; n<shields->count; n++)
                points += shields->entry[n].max * 0.1f;
        }
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

bool SpaceShip::hasSystem(ShipSystem::Type system)
{
    return ShipSystem::get(entity, system) != nullptr;
}

float SpaceShip::getBeamWeaponArc(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponDirection(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponRange(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretArc(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretDirection(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponTurretRotationRate(int index) { return 0.0f; /* TODO */ }

float SpaceShip::getBeamWeaponCycleTime(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponDamage(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponEnergyPerFire(int index) { return 0.0f; /* TODO */ }
float SpaceShip::getBeamWeaponHeatPerFire(int index) { return 0.0f; /* TODO */ }

int SpaceShip::getBeamFrequency() { return 0; /* TODO */ }

void SpaceShip::setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage) { /* TODO */ }

void SpaceShip::setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate) { /* TODO */ }

void SpaceShip::setBeamWeaponTexture(int index, string texture) { /* TODO */ }

void SpaceShip::setBeamWeaponEnergyPerFire(int index, float energy) { /* TODO */ }
void SpaceShip::setBeamWeaponHeatPerFire(int index, float heat) { /* TODO */ }
void SpaceShip::setBeamWeaponArcColor(int index, float r, float g, float b, float fire_r, float fire_g, float fire_b) { /* TODO */ }
void SpaceShip::setBeamWeaponDamageType(int index, EDamageType type) { /* TODO */ }


void SpaceShip::setWeaponTubeCount(int amount)
{
    //TODO
}

int SpaceShip::getWeaponTubeCount()
{
    //TODO
    return 0;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    //TODO
    return MW_None;
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    //TODO
    return;
}

void SpaceShip::setWeaponTubeDirection(int index, float direction)
{
    //TODO
    return;
}

void SpaceShip::setTubeSize(int index, EMissileSizes size)
{
    //TODO
    return;
}

EMissileSizes SpaceShip::getTubeSize(int index)
{
    //TODO
    return MS_Medium;
}

float SpaceShip::getTubeLoadTime(int index)
{
    //TODO
    return 0;
}

void SpaceShip::setTubeLoadTime(int index, float time)
{
    return;
}

void SpaceShip::addBroadcast(int threshold, string message)
{
    if ((threshold < 0) || (threshold > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(ERROR) << "Invalid threshold: " << threshold;
        threshold = 0;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    glm::u8vec4 color = glm::u8vec4(255, 204, 51, 255); //default : yellow, should never be seen

    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        bool addtolog = 0;
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (this->isFriendly(ship))
            {
                color = glm::u8vec4(154, 255, 154, 255); //ally = light green
                addtolog = 1;
            }
            else if ((FactionInfo::getState(this->getFactionId(), ship->getFactionId()) == FVF_Neutral) && ((threshold >= FVF_Neutral)))
            {
                color = glm::u8vec4(128,128,128, 255); //neutral = grey
                addtolog = 1;
            }
            else if ((this->isEnemy(ship)) && (threshold == FVF_Enemy))
            {
                color = glm::u8vec4(255,102,102, 255); //enemy = light red
                addtolog = 1;
            }

            if (addtolog)
            {
                ship->addToShipLog(message, color);
            }
        }
    }
}

std::unordered_map<string, string> SpaceShip::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret = ShipTemplateBasedObject::getGMInfo();
    return ret;
}

bool SpaceShip::isDocked(P<SpaceObject> target)
{
    if (!entity) return false; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return false;
    return port->state == DockingPort::State::Docked && *port->target.getComponent<SpaceObject*>() == *target;
}

P<SpaceObject> SpaceShip::getDockedWith()
{
    if (!entity) return nullptr; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return nullptr;
    if (port->state != DockingPort::State::Docked) return nullptr;
    return *port->target.getComponent<SpaceObject*>();
}

DockingPort::State SpaceShip::getDockingState()
{
    if (!entity) return DockingPort::State::NotDocking; 
    auto port = entity.getComponent<DockingPort>();
    if (!port) return DockingPort::State::NotDocking;
    return port->state;
}

float SpaceShip::getMaxEnergy() { return 0.0f; } // TODO
void SpaceShip::setMaxEnergy(float amount) {} // TODO
float SpaceShip::getEnergy() { return 0.0f; } // TODO
void SpaceShip::setEnergy(float amount) {} // TODO

Speeds SpaceShip::getAcceleration()
{
    //TODO
    return {0.0f, 0.0f};
}

void SpaceShip::setAcceleration(float acceleration, std::optional<float> reverse_acceleration)
{
    //TODO
}

Speeds SpaceShip::getImpulseMaxSpeed()
{
    //TODO
    return {0.0f, 0.0f};
}
void SpaceShip::setImpulseMaxSpeed(float forward_speed, std::optional<float> reverse_speed)
{
    //TODO
}


string SpaceShip::getScriptExportModificationsOnTemplate()
{
    // Exports attributes common to ships as Lua script function calls.
    // Initialize the exported string.
    string ret = "";

    // If traits don't differ from the ship template, don't bother exporting
    // them.
    if (getTypeName() != ship_template->getName())
        ret += ":setTypeName(\"" + getTypeName() + "\")";
    //if (hull_max != ship_template->hull)
    //    ret += ":setHullMax(" + string(hull_max, 0) + ")";
    //if (hull_strength != ship_template->hull)
    //    ret += ":setHull(" + string(hull_strength, 0) + ")";
    //if (impulse_max_speed != ship_template->impulse_speed)
    //    ret += ":setImpulseMaxSpeed(" + string(impulse_max_speed, 1) + ")";
    //if (impulse_max_reverse_speed != ship_template->impulse_reverse_speed)
    //    ret += ":setImpulseMaxReverseSpeed(" + string(impulse_max_reverse_speed, 1) + ")";
    //if (turn_speed != ship_template->turn_speed)
    //    ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
    //if (has_jump_drive != ship_template->has_jump_drive)
    //    ret += ":setJumpDrive(" + string(has_jump_drive ? "true" : "false") + ")";
    //if (jump_drive_min_distance != ship_template->jump_drive_min_distance
    //    || jump_drive_max_distance != ship_template->jump_drive_max_distance)
    //    ret += ":setJumpDriveRange(" + string(jump_drive_min_distance) + ", " + string(jump_drive_max_distance) + ")";
    //if (has_warp_drive != (ship_template->warp_speed > 0))
    //    ret += ":setWarpDrive(" + string(has_warp_drive ? "true" : "false") + ")";
    //if (warp_speed_per_warp_level != ship_template->warp_speed)
    //    ret += ":setWarpSpeed(" + string(warp_speed_per_warp_level) + ")";

    // Shield data
    // Determine whether to export shield data.
    bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    bool add_shields_line = getShieldCount() != ship_template->shield_count;

    // If shield max and level don't differ from the template, don't bother
    // exporting them.
    for(int n = 0; n < getShieldCount(); n++)
    {
        if (getShieldMax(n) != ship_template->shield_level[n])
            add_shields_max_line = true;
        if (getShieldLevel(n) != ship_template->shield_level[n])
            add_shields_line = true;
    }

    // If we're exporting shield max ...
    if (add_shields_max_line)
    {
        ret += ":setShieldsMax(";

        // ... for each shield, export the shield max.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldMax(n));
        }

        ret += ")";
    }

    // If we're exporting shield level ...
    if (add_shields_line)
    {
        ret += ":setShields(";

        // ... for each shield, export the shield level.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldLevel(n));
        }

        ret += ")";
    }

    // Missile weapon data
    /*
    if (weapon_tube_count != ship_template->weapon_tube_count)
        ret += ":setWeaponTubeCount(" + string(weapon_tube_count) + ")";

    for(int n=0; n<weapon_tube_count; n++)
    {
        WeaponTube& tube = weapon_tube[n];
        auto& template_tube = ship_template->weapon_tube[n];
        if (tube.getDirection() != template_tube.direction)
        {
            ret += ":setWeaponTubeDirection(" + string(n) + ", " + string(tube.getDirection(), 0) + ")";
        }
        //TODO: Weapon tube "type_allowed_mask"
        //TODO: Weapon tube "load_time"
        if (tube.getSize() != template_tube.size)
        {
            ret += ":setTubeSize(" + string(n) + ",\"" + getMissileSizeString(tube.getSize()) + "\")";
        }
    }
    for(int n=0; n<MW_Count; n++)
    {
        if (weapon_storage_max[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorageMax(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage_max[n]) + ")";
        if (weapon_storage[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorage(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage[n]) + ")";
    }
    */
    // Beam weapon data
    /*
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].getArc() != ship_template->beams[n].getArc()
         || beam_weapons[n].getDirection() != ship_template->beams[n].getDirection()
         || beam_weapons[n].getRange() != ship_template->beams[n].getRange()
         || beam_weapons[n].getTurretArc() != ship_template->beams[n].getTurretArc()
         || beam_weapons[n].getTurretDirection() != ship_template->beams[n].getTurretDirection()
         || beam_weapons[n].getTurretRotationRate() != ship_template->beams[n].getTurretRotationRate()
         || beam_weapons[n].getCycleTime() != ship_template->beams[n].getCycleTime()
         || beam_weapons[n].getDamage() != ship_template->beams[n].getDamage())
        {
            ret += ":setBeamWeapon(" + string(n) + ", " + string(beam_weapons[n].getArc(), 0) + ", " + string(beam_weapons[n].getDirection(), 0) + ", " + string(beam_weapons[n].getRange(), 0) + ", " + string(beam_weapons[n].getCycleTime(), 1) + ", " + string(beam_weapons[n].getDamage(), 1) + ")";
            ret += ":setBeamWeaponTurret(" + string(n) + ", " + string(beam_weapons[n].getTurretArc(), 0) + ", " + string(beam_weapons[n].getTurretDirection(), 0) + ", " + string(beam_weapons[n].getTurretRotationRate(), 0) + ")";
        }
    }
*/
    return ret;
}

string getMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return "Homing";
    case MW_Nuke:
        return "Nuke";
    case MW_Mine:
        return "Mine";
    case MW_EMP:
        return "EMP";
    case MW_HVLI:
        return "HVLI";
    default:
        return "UNK: " + string(int(missile));
    }
}

string getLocaleMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return tr("missile","Homing");
    case MW_Nuke:
        return tr("missile","Nuke");
    case MW_Mine:
        return tr("missile","Mine");
    case MW_EMP:
        return tr("missile","EMP");
    case MW_HVLI:
        return tr("missile","HVLI");
    default:
        return "UNK: " + string(int(missile));
    }
}


float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency)
{
    if (beam_frequency < 0 || shield_frequency < 0)
        return 1.f;

    float diff = static_cast<float>(abs(beam_frequency - shield_frequency));
    float f1 = sinf(Tween<float>::linear(diff, 0, SpaceShip::max_frequency, 0, float(M_PI) * (1.2f + shield_frequency * 0.05f)) + float(M_PI) / 2.0f);
    f1 = f1 * Tween<float>::easeInCubic(diff, 0, SpaceShip::max_frequency, 1.f, 0.1f);
    f1 = Tween<float>::linear(f1, 1.f, -1.f, 0.5f, 1.5f);
    return f1;
}

string frequencyToString(int frequency)
{
    return string(400 + (frequency * 20)) + "THz";
}

#include "spaceship.hpp"
