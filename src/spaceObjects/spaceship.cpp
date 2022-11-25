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
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/hull.h"

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

std::array<float, SYS_COUNT> SpaceShip::default_system_power_factors{
    /*SYS_Reactor*/     -25.f,
    /*SYS_BeamWeapons*/   3.f,
    /*SYS_MissileSystem*/ 1.f,
    /*SYS_Maneuver*/      2.f,
    /*SYS_Impulse*/       4.f,
    /*SYS_Warp*/          5.f,
    /*SYS_JumpDrive*/     5.f,
    /*SYS_FrontShield*/   5.f,
    /*SYS_RearShield*/    5.f,
};

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    target_rotation = getRotation();
    wormhole_alpha = 0.f;
    weapon_tube_count = 0;
    turn_speed = 10.f;
    combat_maneuver_charge = 1.f;
    combat_maneuver_boost_request = 0.f;
    combat_maneuver_boost_active = 0.f;
    combat_maneuver_strafe_request = 0.f;
    combat_maneuver_strafe_active = 0.f;
    combat_maneuver_boost_speed = 0.0f;
    combat_maneuver_strafe_speed = 0.0f;
    target_id = -1;
    shield_frequency = irandom(0, max_frequency);
    turnSpeed = 0.0f;

    registerMemberReplication(&target_rotation, 1.5f);
    registerMemberReplication(&turnSpeed, 0.1f);
    registerMemberReplication(&wormhole_alpha, 0.5f);
    registerMemberReplication(&weapon_tube_count);
    registerMemberReplication(&target_id);
    registerMemberReplication(&turn_speed);
    registerMemberReplication(&shield_frequency);
    registerMemberReplication(&combat_maneuver_charge, 0.5f);
    registerMemberReplication(&combat_maneuver_boost_request);
    registerMemberReplication(&combat_maneuver_boost_active, 0.2f);
    registerMemberReplication(&combat_maneuver_strafe_request);
    registerMemberReplication(&combat_maneuver_strafe_active, 0.2f);
    registerMemberReplication(&combat_maneuver_boost_speed);
    registerMemberReplication(&combat_maneuver_strafe_speed);

    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        SDL_assert(n < default_system_power_factors.size());
        systems[n].health = 1.0f;
        systems[n].health_max = 1.0f;
        systems[n].power_level = 1.0f;
        systems[n].power_rate_per_second = ShipSystemLegacy::default_power_rate_per_second;
        systems[n].power_request = 1.0f;
        systems[n].coolant_level = 0.0f;
        systems[n].coolant_rate_per_second = ShipSystemLegacy::default_coolant_rate_per_second;
        systems[n].coolant_request = 0.0f;
        systems[n].heat_level = 0.0f;
        systems[n].heat_rate_per_second = ShipSystemLegacy::default_heat_rate_per_second;
        systems[n].hacked_level = 0.0f;
        systems[n].power_factor = default_system_power_factors[n];

        registerMemberReplication(&systems[n].health, 0.1f);
        registerMemberReplication(&systems[n].health_max, 0.1f);
        registerMemberReplication(&systems[n].hacked_level, 0.1f);
    }

    for(int n = 0; n < max_weapon_tubes; n++)
    {
        weapon_tube[n].setParent(this);
        weapon_tube[n].setIndex(n);
    }

    for(int n = 0; n < MW_Count; n++)
    {
        weapon_storage[n] = 0;
        weapon_storage_max[n] = 0;
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }

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
    weapon_tube_count = ship_template->weapon_tube_count;

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
    
    turn_speed = ship_template->turn_speed;
    combat_maneuver_boost_speed = ship_template->combat_maneuver_boost_speed;
    combat_maneuver_strafe_speed = ship_template->combat_maneuver_strafe_speed;

    if (ship_template->warp_speed > 0.0f) {
        auto& warp = entity.getOrAddComponent<WarpDrive>();
        warp.speed_per_level = ship_template->warp_speed;
    }
    if (ship_template->has_jump_drive) {
        auto& jump = entity.getOrAddComponent<JumpDrive>();
        jump.min_distance = ship_template->jump_drive_min_distance;
        jump.max_distance = ship_template->jump_drive_max_distance;
    }
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].setLoadTimeConfig(ship_template->weapon_tube[n].load_time);
        weapon_tube[n].setDirection(ship_template->weapon_tube[n].direction);
        weapon_tube[n].setSize(ship_template->weapon_tube[n].size);
        for(int m=0; m<MW_Count; m++)
        {
            if (ship_template->weapon_tube[n].type_allowed_mask & (1 << m))
                weapon_tube[n].allowLoadOf(EMissileWeapons(m));
            else
                weapon_tube[n].disallowLoadOf(EMissileWeapons(m));
        }
    }
    //shipTemplate->has_cloaking;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = weapon_storage_max[n] = ship_template->weapon_storage[n];

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
    for(int n = 0; n < SYS_COUNT; n++)
    {
        ESystem ship_system = static_cast<ESystem>(n);

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
        if (ship_system == SYS_JumpDrive)
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

void SpaceShip::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    // If not on long-range radar ...
    if (!long_range)
    {
        // ... and the ship being drawn is either not our ship or has been
        // scanned ...
        if (!my_spaceship || getScannedStateFor(my_spaceship) >= SS_SimpleScan)
        {
            // ... draw and show shield indicators on our radar.
            drawShieldsOnRadar(renderer, position, scale, rotation, 1.f, true);
        } else {
            // Otherwise, draw the indicators, but don't show them.
            drawShieldsOnRadar(renderer, position, scale, rotation, 1.f, false);
        }
    }
}

void SpaceShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    auto physics = entity.getComponent<sp::Physics>();

    float rotationDiff;
    if (fabs(turnSpeed) < 0.0005f) {
        rotationDiff = angleDifference(getRotation(), target_rotation);
    } else {
        rotationDiff = turnSpeed;
    }

    if (physics) {
        if (rotationDiff > 1.0f)
            physics->setAngularVelocity(turn_speed * getSystemEffectiveness(SYS_Maneuver));
        else if (rotationDiff < -1.0f)
            physics->setAngularVelocity(-turn_speed * getSystemEffectiveness(SYS_Maneuver));
        else
            physics->setAngularVelocity(rotationDiff * turn_speed * getSystemEffectiveness(SYS_Maneuver));
    }

    if (combat_maneuver_boost_active > combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active -= delta;
        if (combat_maneuver_boost_active < combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_boost_active < combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active += delta;
        if (combat_maneuver_boost_active > combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active -= delta;
        if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }
    if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active += delta;
        if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }

    // If the ship is making a combat maneuver ...
    if (combat_maneuver_boost_active != 0.0f || combat_maneuver_strafe_active != 0.0f)
    {
        // ... consume its combat maneuver boost.
        combat_maneuver_charge -= fabs(combat_maneuver_boost_active) * delta / combat_maneuver_boost_max_time;
        combat_maneuver_charge -= fabs(combat_maneuver_strafe_active) * delta / combat_maneuver_strafe_max_time;

        // Use boost only if we have boost available.
        if (combat_maneuver_charge <= 0.0f)
        {
            combat_maneuver_charge = 0.0f;
            combat_maneuver_boost_request = 0.0f;
            combat_maneuver_strafe_request = 0.0f;
        }else if (physics)
        {
            auto forward = vec2FromAngle(getRotation());
            physics->setVelocity(physics->getVelocity() + forward * combat_maneuver_boost_speed * combat_maneuver_boost_active);
            physics->setVelocity(physics->getVelocity() + vec2FromAngle(getRotation() + 90) * combat_maneuver_strafe_speed * combat_maneuver_strafe_active);
        }
    // If the ship isn't making a combat maneuver, recharge its boost.
    }else if (combat_maneuver_charge < 1.0f)
    {
        combat_maneuver_charge += (delta / combat_maneuver_charge_time) * (getSystemEffectiveness(SYS_Maneuver) + getSystemEffectiveness(SYS_Impulse)) / 2.0f;
        if (combat_maneuver_charge > 1.0f)
            combat_maneuver_charge = 1.0f;
    }

    // Add heat to systems consuming combat maneuver boost.
    addHeat(SYS_Impulse, fabs(combat_maneuver_boost_active) * delta * heat_per_combat_maneuver_boost);
    addHeat(SYS_Maneuver, fabs(combat_maneuver_strafe_active) * delta * heat_per_combat_maneuver_strafe);

    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].update(delta);
    }

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].hacked_level = std::max(0.0f, systems[n].hacked_level - delta / unhack_time);
        systems[n].health = std::min(systems[n].health,systems[n].health_max);
    }

    model_info.engine_scale = std::abs(getAngularVelocity() / turn_speed);
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

float SpaceShip::getShieldRechargeRate(int shield_index)
{
    float rate = 0.3f;
    rate *= getSystemEffectiveness(getShieldSystemForShieldIndex(shield_index));
    auto port = entity.getComponent<DockingPort>();
    if (port && port->state == DockingPort::State::Docked && port->target)
    {
        auto bay = port->target.getComponent<DockingBay>();
        if (bay && (bay->flags & DockingBay::ChargeShield))
            rate *= 4.0f;
    }
    return rate;
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
        return reactor->use_energy(amount);
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

std::vector<std::pair<ESystem, float>> SpaceShip::getHackingTargets()
{
    std::vector<std::pair<ESystem, float>> results;
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (n != SYS_Reactor && hasSystem(ESystem(n)))
        {
            results.emplace_back(ESystem(n), systems[n].hacked_level);
        }
    }
    return results;
}

void SpaceShip::hackFinished(P<SpaceObject> source, string target)
{
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (hasSystem(ESystem(n)))
        {
            if (target == getSystemName(ESystem(n)))
            {
                systems[n].hacked_level = std::min(1.0f, systems[n].hacked_level + 0.5f);
                return;
            }
        }
    }
    LOG(WARNING) << "Unknown hacked target: " << target;
}

float SpaceShip::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    float frequency_damage_factor = 1.f;
    if (info.type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
    {
        frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shield_frequency);
    }
    ESystem system = getShieldSystemForShieldIndex(shield_index);

    //Shield damage reduction curve. Damage reduction gets slightly exponetial effective with power.
    // This also greatly reduces the ineffectiveness at low power situations.
    float shield_damage_exponent = 1.6f;
    float shield_damage_divider = 7.0f;
    float shield_damage_factor = 1.0f + powf(1.0f, shield_damage_exponent) / shield_damage_divider-powf(getSystemEffectiveness(system), shield_damage_exponent) / shield_damage_divider;

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
        if (info.system_target != SYS_None)
        {
            //Target specific system
            float system_damage = (damage_amount / hull->max) * 2.0f;
            if (info.type == DT_Energy)
                system_damage *= 3.0f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[info.system_target].health -= system_damage;
            if (systems[info.system_target].health < -1.0f)
                systems[info.system_target].health = -1.0f;

            for(int n=0; n<2; n++)
            {
                ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull->max) * 1.0f;
                systems[random_system].health -= system_damage;
                if (systems[random_system].health < -1.0f)
                    systems[random_system].health = -1.0f;
            }

            if (info.type == DT_Energy)
                damage_amount *= 0.02f;
            else
                damage_amount *= 0.5f;
        }else{
            ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (damage_amount / hull->max) * 3.0f;
            if (info.type == DT_Energy)
                system_damage *= 2.5f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[random_system].health -= system_damage;
            if (systems[random_system].health < -1.0f)
                systems[random_system].health = -1.0f;
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
        for(int n=0; n<shield_count; n++)
            points += shield_max[n] * 0.1f;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

bool SpaceShip::hasSystem(ESystem system)
{
    switch(system)
    {
    case SYS_None:
    case SYS_COUNT:
        return false;
    case SYS_Warp:
        return entity.hasComponent<WarpDrive>();
    case SYS_JumpDrive:
        return entity.hasComponent<JumpDrive>();
    case SYS_MissileSystem:
        return weapon_tube_count > 0;
    case SYS_FrontShield:
        return shield_count > 0;
    case SYS_RearShield:
        return shield_count > 1;
    case SYS_Reactor:
        return entity.hasComponent<Reactor>();
    case SYS_BeamWeapons:
        return entity.hasComponent<BeamWeaponSys>();
    case SYS_Maneuver:
        return turn_speed > 0.0f;
    case SYS_Impulse:
        return entity.hasComponent<ImpulseEngine>();
    }
    return true;
}

float SpaceShip::getSystemEffectiveness(ESystem system)
{
    float power = systems[system].power_level;

    // Substract the hacking from the power, making double hacked systems run at 25% efficiency.
    power = std::max(0.0f, power - systems[system].hacked_level * 0.75f);

    // Degrade all systems except the reactor once energy level drops below 10.
    if (system != SYS_Reactor)
    {
        auto reactor = entity.getComponent<Reactor>();
        if (reactor) {
            if (reactor->energy < 10.0f && reactor->energy > 0.0f && power > 0.0f)
                power = std::min(power * reactor->energy / 10.0f, power);
            else if (reactor->energy <= 0.0f || power <= 0.0f)
                power = 0.0f;
        }
    }

    // Degrade damaged systems.
    if (gameGlobalInfo && gameGlobalInfo->use_system_damage)
        return std::max(0.0f, power * systems[system].health);

    // If a system cannot be damaged, excessive heat degrades it.
    return std::max(0.0f, power * (1.0f - systems[system].heat_level));
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
    weapon_tube_count = std::max(0, std::min(amount, max_weapon_tubes));
    for(int n=weapon_tube_count; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].forceUnload();
    }
}

int SpaceShip::getWeaponTubeCount()
{
    return weapon_tube_count;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MW_None;
    if (!weapon_tube[index].isLoaded())
        return MW_None;
    return weapon_tube[index].getLoadType();
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].disallowLoadOf(type);
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    for(int n=0; n<MW_Count; n++)
        weapon_tube[index].disallowLoadOf(EMissileWeapons(n));
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::setWeaponTubeDirection(int index, float direction)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].setDirection(direction);
}

void SpaceShip::setTubeSize(int index, EMissileSizes size)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].setSize(size);
}

EMissileSizes SpaceShip::getTubeSize(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MS_Medium;
    return weapon_tube[index].getSize();
}

float SpaceShip::getTubeLoadTime(int index)
{
    if (index < 0 || index >= weapon_tube_count) {
        return 0;
    }
    return weapon_tube[index].getLoadTimeConfig();
}

void SpaceShip::setTubeLoadTime(int index, float time)
{
    if (index < 0 || index >= weapon_tube_count) {
        return;
    }
    weapon_tube[index].setLoadTimeConfig(time);
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
    if (turn_speed != ship_template->turn_speed)
        ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
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
