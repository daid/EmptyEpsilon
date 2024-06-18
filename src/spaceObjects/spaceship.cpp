#include "spaceship.h"

#include <array>

#include <i18n.h>

#include "mesh.h"
#include "random.h"
#include "playerInfo.h"
#include "particleEffect.h"
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
#include "components/target.h"
#include "components/shiplog.h"
#include "ecs/query.h"

#include <SDL_assert.h>


SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
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
            shields->frequency = irandom(0, BeamWeaponSys::max_frequency);
    }
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
SpaceShip::~SpaceShip()
{
}

void SpaceShip::applyTemplateValues()
{
    /*
    for(int n=0; n<16; n++)
    {
        if (ship_template->beams[n].getRange() > 0.0f) {
            auto& beamweaponsystem = entity.getOrAddComponent<BeamWeaponSys>();
            beamweaponsystem.mounts.resize(n);
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
        tubes.mounts.resize(ship_template->weapon_tube_count);
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
    //model_info.setData(ship_template->model_data);
    */
}

void SpaceShip::draw3DTransparent()
{
    //if (!ship_template) return;
    ShipTemplateBasedObject::draw3DTransparent();
/*  TODO
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
    */
}

void SpaceShip::updateDynamicRadarSignature()
{
    // Adjust radar_signature dynamically based on current state and activity.
    // radar_signature becomes the ship's baseline radar signature.
    DynamicRadarSignatureInfo signature_delta;

    /* TODO
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
    */
}

void SpaceShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    /*TODO
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
        model_info.warp_scale = (10.0f - jump->delay) / 10.0f;
    else
        model_info.warp_scale = 0.f;
    */
    
    updateDynamicRadarSignature();
}

P<SpaceObject> SpaceShip::getTarget()
{
    auto target = entity.getComponent<Target>();
    if (!target)
        return nullptr;
    auto obj = target->entity.getComponent<SpaceObject*>();
    if (!obj)
        return nullptr;
    return *obj;
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

void SpaceShip::setScanState(ScanState::State state)
{
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        setScannedStateForFaction(faction_entity, state);
    }
}

void SpaceShip::setScanStateByFaction(string faction_name, ScanState::State state)
{
    setScannedStateForFaction(Faction::find(faction_name), state);
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Deprecated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (getScannedStateForFaction(faction_entity) > ScanState::State::NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Deprecated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (getScannedStateForFaction(faction_entity) >= ScanState::State::FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other->entity) >= ScanState::State::FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other->entity) >= ScanState::State::FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(sp::ecs::Entity faction_entity)
{
    return getScannedStateForFaction(faction_entity) >= ScanState::State::FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(sp::ecs::Entity faction_entity)
{
    return getScannedStateForFaction(faction_entity) >= ScanState::State::FullScan;
}

void SpaceShip::hackFinished(sp::ecs::Entity source, ShipSystem::Type target)
{
    auto sys = ShipSystem::get(entity, target);
    if (sys)
        sys->hacked_level = std::min(1.0f, sys->hacked_level + 0.5f);
}

bool SpaceShip::hasSystem(ShipSystem::Type system)
{
    return ShipSystem::get(entity, system) != nullptr;
}

void SpaceShip::addBroadcast(FactionRelation threshold, string message)
{
    if ((int(threshold) < 0) || (int(threshold) > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(Error, "Invalid threshold: ", int(threshold));
        threshold = FactionRelation::Enemy;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    glm::u8vec4 color = glm::u8vec4(255, 204, 51, 255); //default : yellow, should never be seen

    for(auto [ship, logs] : sp::ecs::Query<ShipLog>())
    {
        bool addtolog = false;
        if (Faction::getRelation(entity, ship) == FactionRelation::Friendly)
        {
            color = glm::u8vec4(154, 255, 154, 255); //ally = light green
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Neutral && int(threshold) >= int(FactionRelation::Neutral))
        {
            color = glm::u8vec4(128,128,128, 255); //neutral = grey
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Enemy && threshold == FactionRelation::Enemy)
        {
            color = glm::u8vec4(255,102,102, 255); //enemy = light red
            addtolog = true;
        }

        if (addtolog)
        {
            logs.entries.push_back({gameGlobalInfo->getMissionTime() + string(": "), message, color});
        }
    }
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

string SpaceShip::getScriptExportModificationsOnTemplate()
{
    // Exports attributes common to ships as Lua script function calls.
    // Initialize the exported string.
    string ret = "";

    // If traits don't differ from the ship template, don't bother exporting
    // them.
    //if (getTypeName() != ship_template->getName())
    //    ret += ":setTypeName(\"" + getTypeName() + "\")";
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
    //bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    //bool add_shields_line = getShieldCount() != ship_template->shield_count;

    // If shield max and level don't differ from the template, don't bother
    // exporting them.
    /*
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
    */

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

#include "spaceship.hpp"
