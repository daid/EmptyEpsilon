#include "ai/ai.h"
#include "ai/aiFactory.h"
#include "random.h"
#include "components/ai.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/hull.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/target.h"
#include "components/faction.h"
#include "components/collision.h"
#include "components/radar.h"
#include "components/moveto.h"
#include "systems/collision.h"
#include "systems/jumpsystem.h"
#include "systems/docking.h"
#include "systems/missilesystem.h"
#include "systems/radarblock.h"
#include "systems/warpsystem.h"
#include "ecs/query.h"


REGISTER_SHIP_AI(ShipAI, "default");

ShipAI::ShipAI(sp::ecs::Entity owner)
: owner(owner)
{
    missile_fire_delay = 0.0;

    has_missiles = false;
    has_beams = false;
    beam_weapon_range = 0.0;
    weapon_direction = EWeaponDirection::Front;

    update_target_delay = 0.0;
}

bool ShipAI::canSwitchAI()
{
    return true;
}

void ShipAI::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 draw_position, float scale)
{
    auto transform = owner.getComponent<sp::Transform>();
    if (!transform) return;
    auto world_position = transform->getPosition();
    auto target = owner.getComponent<Target>();
    if (target)
    {
        if (auto t = target->entity.getComponent<sp::Transform>()) {
            auto v = t->getPosition() - world_position;
            renderer.drawLine(draw_position, draw_position + v * scale, glm::u8vec4(255, 128, 128, 64));
        }
    }

    auto p0 = draw_position;
    for(unsigned int n=0; n<pathPlanner.route.size(); n++)
    {
        auto p1 = draw_position + (pathPlanner.route[n] - world_position) * scale;
        renderer.drawLine(p0, p1, glm::u8vec4(255, 255, 255, 64));
        p0 = p1;
    }
}

void ShipAI::run(float delta)
{
    auto thrusters = owner.getComponent<ManeuveringThrusters>();
    if (thrusters) thrusters->stop();

    auto impulse = owner.getComponent<ImpulseEngine>();
    if (impulse)
        impulse->request = 0.0f;
    auto warp = owner.getComponent<WarpDrive>();
    if (warp)
        warp->request = 0;

    // Update ranges before calculating
    if (auto lrr = owner.getComponent<LongRangeRadar>()) {
        long_range = lrr->long_range;
        relay_range = long_range * 2.0f;
        short_range = lrr->short_range;
    }

    updateWeaponState(delta);
    if (update_target_delay > 0.0f)
    {
        update_target_delay -= delta;
    }else{
        update_target_delay = random(0.25, 0.5);
        updateTarget();
    }

    //If we have a target and weapons, engage the target.
    if (owner.hasComponent<Target>() && (has_missiles || has_beams))
    {
        runAttack(owner.getComponent<Target>()->entity);
    }else{
        runOrders();
    }
}

static int getDirectionIndex(float direction, float arc)
{
    if (fabs(angleDifference(direction, 0.0f)) < arc / 2.0f)
        return 0;
    if (fabs(angleDifference(direction, 90.0f)) < arc / 2.0f)
        return 1;
    if (fabs(angleDifference(direction, 180.0f)) < arc / 2.0f)
        return 2;
    if (fabs(angleDifference(direction, 270.0f)) < arc / 2.0f)
        return 3;
    return -1;
}

void ShipAI::updateWeaponState(float delta)
{
    if (missile_fire_delay > 0.0f)
        missile_fire_delay -= delta;

    //Update the weapon state, figure out which direction is our main attack vector. If we have missile and/or beam weapons, and what we should preferer.
    has_missiles = false;
    has_beams = false;
    beam_weapon_range = 0;
    best_missile_type = MW_None;

    float tube_strength_per_direction[4] = {0, 0, 0, 0};
    float beam_strength_per_direction[4] = {0, 0, 0, 0};

    //If we have weapon tubes, load them with torpedoes
    auto tubes = owner.getComponent<MissileTubes>();
    if (tubes) {
        for(auto& tube : tubes->mounts)
        {
            if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_EMP] > 0 && tube.canLoad(MW_EMP))
                MissileSystem::startLoad(owner, tube, MW_EMP);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_Nuke] > 0 && tube.canLoad(MW_Nuke))
                MissileSystem::startLoad(owner, tube, MW_Nuke);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_Homing] > 0 && tube.canLoad(MW_Homing))
                MissileSystem::startLoad(owner, tube, MW_Homing);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_HVLI] > 0 && tube.canLoad(MW_HVLI))
                MissileSystem::startLoad(owner, tube, MW_HVLI);

            //When the tube is loading or loaded, add the relative strenght of this tube to the direction of this tube.
            if (tube.state == MissileTubes::MountPoint::State::Loading || tube.state == MissileTubes::MountPoint::State::Loaded)
            {
                int index = getDirectionIndex(tube.direction, 90);
                if (index >= 0)
                    tube_strength_per_direction[index] += getMissileWeaponStrength(tube.type_loaded) / tube.load_time;
            }
        }
    }

    auto beamsystem = owner.getComponent<BeamWeaponSys>();
    if (beamsystem) {
        for(auto& mount : beamsystem->mounts) {
            if (mount.range > 0.0f) {
                int index = getDirectionIndex(mount.direction, mount.arc);
                if (index >= 0 && mount.cycle_time > 0.0f)
                    beam_strength_per_direction[index] += mount.damage / mount.cycle_time;
            }
        }
    }

    int best_tube_index = -1;
    float best_tube_strenght = 0.0;
    int best_beam_index = -1;
    float best_beam_strenght = 0.0;
    for(int n=0; n<4; n++)
    {
        if (best_tube_strenght < tube_strength_per_direction[n])
        {
            best_tube_index = n;
            best_tube_strenght = tube_strength_per_direction[n];
        }
        if (best_beam_strenght < beam_strength_per_direction[n])
        {
            best_beam_index = n;
            best_beam_strenght = beam_strength_per_direction[n];
        }
    }

    has_beams = best_beam_index > -1;
    has_missiles = best_tube_index > -1;

    if (has_beams && beamsystem)
    {
        //Figure out our beam weapon range.
        for(auto& mount : beamsystem->mounts) {
            if (mount.range > 0.0f) {
                int index = getDirectionIndex(mount.direction, mount.arc);
                if (index == best_beam_index && mount.cycle_time > 0.0f)
                    beam_weapon_range += mount.range * (mount.damage / mount.cycle_time) / beam_strength_per_direction[index];
            }
        }
    }
    if (has_missiles && tubes)
    {
        float best_missile_strength = 0.0;
        for(auto& tube : tubes->mounts)
        {
            if (tube.state == MissileTubes::MountPoint::State::Loading || tube.state == MissileTubes::MountPoint::State::Loaded) {
                int index = getDirectionIndex(tube.direction, 90);
                if (index == best_tube_index) {
                    EMissileWeapons type = tube.type_loaded;
                    float strenght = getMissileWeaponStrength(type);
                    if (strenght > best_missile_strength)
                    {
                        best_missile_strength = strenght;
                        best_missile_type = type;
                    }
                }
            }
        }
    }

    int direction_index = best_tube_index;
    float* strength_per_direction = tube_strength_per_direction;
    if (best_beam_strenght > best_tube_strenght)
    {
        direction_index = best_beam_index;
        strength_per_direction = beam_strength_per_direction;
    }
    switch(direction_index)
    {
    case -1:
    case 0:
        weapon_direction = EWeaponDirection::Front;
        break;
    case 1:
    case 3:
        if (fabs(strength_per_direction[1] - strength_per_direction[3]) < 1.0f)
            weapon_direction = EWeaponDirection::Side;
        else if (direction_index == 1)
            weapon_direction = EWeaponDirection::Right;
        else
            weapon_direction = EWeaponDirection::Left;
        break;
    case 2:
        weapon_direction = EWeaponDirection::Rear;
        break;
    }
}

void ShipAI::updateTarget()
{
    sp::ecs::Entity target = owner.hasComponent<Target>() ? owner.getComponent<Target>()->entity : sp::ecs::Entity{};
    sp::ecs::Entity new_target;
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return;
    auto position = ot->getPosition();
    auto ai = owner.getComponent<AIController>();
    if (!ai) return;

    // Check if we lost our target because it entered a nebula.
    if (target && RadarBlockSystem::isRadarBlockedFrom(position, target, short_range))
    {
        // When we're roaming, and we lost our target in a nebula, set the
        // "fly to" position to the last known position of the enemy target.
        if (ai->orders == AIOrder::Roaming)
        {
            ai->orders = AIOrder::Roaming;
            auto tt = target.getComponent<sp::Transform>();
            if (tt)
                ai->order_target_location = tt->getPosition();
        }

        target = {};
    }

    // If the target is no longer an enemy, clear the target.
    if (target && Faction::getRelation(owner, target) != FactionRelation::Enemy)
        target = {};

    // If we're roaming, select the best target within long-range radar range.
    if (ai->orders == AIOrder::Roaming)
    {
        if (target)
            new_target = findBestTarget(position, short_range + 2000.0f);
        else
            new_target = findBestTarget(position, long_range);
    }

    // If we're holding ground or flying toward a destination, select only
    // targets within 2U of our short-range radar range.
    if (ai->orders == AIOrder::StandGround || ai->orders == AIOrder::FlyTowards)
    {
        new_target = findBestTarget(position, short_range + 2000.0f);
    }

    // If we're defending a position, select only targets within 2U of our
    // short-range radar range.
    if (ai->orders == AIOrder::DefendLocation)
    {
        new_target = findBestTarget(ai->order_target_location, short_range + 2000.0f);
    }

    // If we're flying in formation, select targets only within short-range
    // radar range.
    if (ai->orders == AIOrder::FlyFormation && ai->order_target)
    {
        auto order_target_target = ai->order_target.getComponent<Target>();

        if (order_target_target) {
            if (auto ottt = order_target_target->entity.getComponent<sp::Transform>()) {
                if (glm::length2(ottt->getPosition() - position) < short_range*short_range) {
                    new_target = order_target_target->entity;
                }
            }
        }
    }

    // If we're defending a target, select only targets within 2U of our
    // short-range radar range.
    if (ai->orders == AIOrder::DefendTarget && ai->order_target)
    {
        auto ott = ai->order_target.getComponent<sp::Transform>();
        if (ott)
            new_target = findBestTarget(ott->getPosition(), short_range + 2000.0f);
    }

    if (ai->orders == AIOrder::Attack)
    {
        new_target = ai->order_target;
    }

    // Check if we need to drop the current target.
    if (auto tt = target.getComponent<sp::Transform>())
    {
        float target_distance = glm::length(tt->getPosition() - position);

        // Release the target if it moves more than short-range radar range +
        // 3U away from us or our destination.
        if ((ai->orders == AIOrder::StandGround
            || ai->orders == AIOrder::DefendLocation
            || ai->orders == AIOrder::DefendTarget
            || ai->orders == AIOrder::FlyTowards) && (target_distance > short_range + 3000.0f))
        {
            target = {};
        }

        // If we're flying in formation, release the target if it moves more
        // than short-range radar range + 1U away from us.
        if (ai->orders == AIOrder::FlyFormation && target_distance > short_range + 1000.0f)
        {
            target = {};
        }

        // Don't target anything if we're idling, flying blind, or docking.
        if (ai->orders == AIOrder::Idle
            || ai->orders == AIOrder::FlyTowardsBlind
            || ai->orders == AIOrder::Dock)
        {
            target = {};
        }
    }

    // Check if we want to switch to a new target.
    if (new_target)
    {
        if (!target || betterTarget(new_target, target))
        {
            target = new_target;
        }
    }

    // If we still don't have a target, set that on the owner.
    if (!target)
    {
        owner.removeComponent<Target>();
    }
    // Otherwise, set the new target on the owner.
    else
    {
        owner.getOrAddComponent<Target>().entity = target;
    }
}

void ShipAI::runOrders()
{
    auto ai = owner.getComponent<AIController>();
    auto docking_port = owner.getComponent<DockingPort>();
    auto radius = 0.0f;
    if (auto physics = owner.getComponent<sp::Physics>())
        radius = physics->getSize().x;

    //When we are not attacking a target, follow orders
    switch(ai->orders)
    {
    case AIOrder::Idle:            //Don't do anything, don't even attack.
        pathPlanner.clear();
        break;
    case AIOrder::Roaming:         //Fly around and engage at will, without a clear target
        //Could mean 3 things
        // 1) we are looking for a target
        // 2) we ran out of missiles
        // 3) we have no weapons
        if (auto ot = owner.getComponent<sp::Transform>()) {
            if (has_missiles || has_beams)
            {
                auto new_target = findBestTarget(ot->getPosition(), relay_range);
                if (new_target)
                {
                    owner.getOrAddComponent<Target>().entity = new_target;
                }else{
                    auto diff = ai->order_target_location - ot->getPosition();
                    if (glm::length2(diff) < 1000.0f*1000.0f) {
                        ai->orders = AIOrder::Roaming;
                        ai->order_target_location = ot->getPosition() + glm::vec2(random(-long_range, long_range), random(-long_range, long_range));
                    }
                    flyTowards(ai->order_target_location);
                }
            }else{
                auto tubes = owner.getComponent<MissileTubes>();
                if (tubes && tubes->mounts.size() > 0)
                {
                    // Find a station which can re-stock our weapons.
                    auto new_target = findBestMissileRestockTarget(ot->getPosition(), long_range);
                    if (new_target)
                    {
                        ai->orders = AIOrder::Retreat;
                        ai->order_target = new_target;
                    }else{
                        auto diff = ai->order_target_location - ot->getPosition();
                        if (glm::length2(diff) < 1000.0f*1000.0f) {
                            ai->orders = AIOrder::Roaming;
                            ai->order_target_location = ot->getPosition() + glm::vec2(random(-long_range, long_range), random(-long_range, long_range));
                        }
                        flyTowards(ai->order_target_location);
                    }
                }else{
                    pathPlanner.clear();
                }
            }
        }
        break;
    case AIOrder::StandGround:     //Keep current position, do not fly away, but attack nearby targets.
        pathPlanner.clear();
        break;
    case AIOrder::FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
    case AIOrder::FlyTowardsBlind: //Fly towards [order_target_location], not attacking anything
        flyTowards(ai->order_target_location);
        if (auto ot = owner.getComponent<sp::Transform>()) {
            if (glm::length2(ot->getPosition() - ai->order_target_location) < radius*radius)
            {
                if (ai->orders == AIOrder::FlyTowards)
                    ai->orders = AIOrder::DefendLocation;
                else
                    ai->orders = AIOrder::Idle;
            }
        }
        break;
    case AIOrder::DefendLocation:  //Defend against enemies getting close to [order_target_location]
        if (auto ot = owner.getComponent<sp::Transform>())
        {
            glm::vec2 target_position = ai->order_target_location;
            target_position += vec2FromAngle(vec2ToAngle(target_position - ot->getPosition()) + 170.0f) * 1500.0f;
            flyTowards(target_position);
        }
        break;
    case AIOrder::DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AIOrder::Roaming if the target is destroyed)
        if (auto tt = ai->order_target.getComponent<sp::Transform>())
        {
            if (auto ot = owner.getComponent<sp::Transform>()) {
                auto target_position = tt->getPosition();
                float circle_distance = 3000.0f;
                target_position += vec2FromAngle(vec2ToAngle(target_position - ot->getPosition()) + 170.0f) * circle_distance;
                flyTowards(target_position);
            }
        }else{
            ai->orders = AIOrder::Roaming;  //We pretty much lost our defending target, so just start roaming.
        }
        break;
    case AIOrder::FlyFormation:    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
        if (ai->order_target)
        {
            flyFormation(ai->order_target, ai->order_target_location);
        }else{
            ai->orders = AIOrder::Roaming;
        }
        break;
    case AIOrder::Attack:          //Attack [order_target] very specificly.
        pathPlanner.clear();
        break;
    case AIOrder::Retreat:
        if ((docking_port && docking_port->state == DockingPort::State::Docked && docking_port->target) && ai->order_target)
        {
            auto bay = docking_port->target.getComponent<DockingBay>();
            bool allow_undock = true;
            if (bay) {
                if (bay->flags & DockingBay::RestockMissiles)
                {
                    auto tubes = owner.getComponent<MissileTubes>();
                    if (tubes) {
                        for(int n = 0; n < MW_Count; n++)
                        {
                            if (tubes->storage[n] < tubes->storage_max[n])
                            {
                                allow_undock = false;
                                break;
                            }
                        }
                    }
                }
                if (bay->flags & DockingBay::Repair)
                {
                    auto hull = owner.getComponent<Hull>();
                    if (hull && hull->current < hull->max)
                        allow_undock = false;
                }
            }
            if (allow_undock)
            {
                ai->orders = AIOrder::Roaming;
                break;
            }
        }else if (auto ot = owner.getComponent<sp::Transform>()) {
            auto new_target = findBestMissileRestockTarget(ot->getPosition(), relay_range);
            if (new_target)
            {
                ai->orders = AIOrder::Retreat;
                ai->order_target = new_target;
            }
        }
        [[fallthrough]]; // continue with docking or roaming
    case AIOrder::Dock:            //Dock with [order_target]
        if (ai->order_target && docking_port)
        {
            if (docking_port->state == DockingPort::State::NotDocking || docking_port->target != ai->order_target)
            {
                auto ott = ai->order_target.getComponent<sp::Transform>();
                auto ot = owner.getComponent<sp::Transform>();
                if (ot && ott) {
                    auto target_position = ott->getPosition();
                    auto diff = ot->getPosition() - target_position;
                    float dist = glm::length(diff);
                    auto target_radius = 0.0f;
                    if (auto physics = ai->order_target.getComponent<sp::Physics>())
                        target_radius = physics->getSize().x;
                    if (dist < 600 + target_radius)
                    {
                        DockingSystem::requestDock(owner, ai->order_target);
                    }else{
                        target_position += (diff / dist) * 500.0f;
                        flyTowards(target_position);
                    }
                } else if (ott && docking_port->state == DockingPort::State::Docked) {
                    DockingSystem::requestUndock(owner);
                }
            }
        }else{
            ai->orders = AIOrder::Roaming;  //Nothing to dock, just fall back to roaming.
        }
        break;
    }
}

void ShipAI::runAttack(sp::ecs::Entity target)
{
    auto ai = owner.getComponent<AIController>();
    if (!ai) return;
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return;
    auto tt = target.getComponent<sp::Transform>();
    if (!tt) return;
    float attack_distance = 4000.0;
    if (has_missiles && best_missile_type == MW_HVLI)
        attack_distance = 2500.0;
    if (has_beams)
        attack_distance = beam_weapon_range * 0.7f;

    auto position_diff = tt->getPosition() - ot->getPosition();
    float distance = glm::length(position_diff);

    // missile attack
    if (distance < 4500 && has_missiles)
    {
        auto tubes = owner.getComponent<MissileTubes>();
        for(auto& tube : tubes->mounts)
        {
            if (tube.state == MissileTubes::MountPoint::State::Loaded && missile_fire_delay <= 0.0f)
            {
                float target_angle = calculateFiringSolution(target, tube);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    MissileSystem::fire(owner, tube, target_angle, target);
                    missile_fire_delay = tube.load_time / tubes->mounts.size() / 2.0f;
                }
            }
        }
    }

    if (ai->orders == AIOrder::StandGround)
    {
        auto thrusters = owner.getComponent<ManeuveringThrusters>();
        if (thrusters) thrusters->target = vec2ToAngle(position_diff);
    }else{
        if (weapon_direction == EWeaponDirection::Side || weapon_direction == EWeaponDirection::Left || weapon_direction == EWeaponDirection::Right)
        {
            //We have side beams, find out where we want to attack from.
            auto target_position = tt->getPosition();
            auto diff = target_position - ot->getPosition();
            float angle = vec2ToAngle(diff);
            if ((weapon_direction == EWeaponDirection::Side && angleDifference(angle, ot->getRotation()) > 0) || weapon_direction == EWeaponDirection::Left)
                angle += 160;
            else
                angle -= 160;
            auto target_radius = 0.0f;
            if (auto physics = target.getComponent<sp::Physics>())
                target_radius = physics->getSize().x;
            target_position += vec2FromAngle(angle) * (attack_distance + target_radius);
            flyTowards(target_position, 0);
        }else{
            flyTowards(tt->getPosition(), attack_distance);
        }
    }
}

void ShipAI::flyTowards(glm::vec2 target, float keep_distance)
{
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) {
        auto docking_port = owner.getComponent<DockingPort>();
        if (docking_port && docking_port->state == DockingPort::State::Docked)
            DockingSystem::requestUndock(owner);
        return;
    }
    auto my_radius = 300.0f;
    if (auto physics = owner.getComponent<sp::Physics>()) my_radius = physics->getSize().x;
    pathPlanner.plan(my_radius, ot->getPosition(), target);

    if (pathPlanner.route.size() > 0)
    {
        auto docking_port = owner.getComponent<DockingPort>();
        if (docking_port && docking_port->state == DockingPort::State::Docked)
            DockingSystem::requestUndock(owner);
        else if (docking_port && docking_port->state == DockingPort::State::Docking)
            DockingSystem::abortDock(owner);

        auto diff = pathPlanner.route[0] - ot->getPosition();
        float distance = glm::length(diff);

        //Normal flying towards target code
        auto target_rotation = vec2ToAngle(diff);
        auto thrusters = owner.getComponent<ManeuveringThrusters>();
        if (thrusters) thrusters->target = target_rotation;
        float rotation_diff = fabs(angleDifference(target_rotation, ot->getRotation()));

        auto warp = owner.getComponent<WarpDrive>();
        auto jump = owner.getComponent<JumpDrive>();
        if ((warp || jump) && !WarpSystem::isWarpJammed(owner))
        {
            if (warp)
                warp->request = (rotation_diff < 30.0f && distance > 2000.0f) ? 1.0f : 0.0f;
            if (distance > 10000 && jump && jump->delay <= 0.0f && jump->charge >= jump->max_distance)
            {
                if (rotation_diff < 1.0f)
                {
                    float jump_distance = distance;
                    if (pathPlanner.route.size() < 2)
                    {
                        jump_distance -= 3000;
                        if (has_missiles)
                            jump_distance -= 5000;
                    }
                    if (jump->max_distance == 50000)
                    {   //If the ship has the default max jump drive distance of 50k, then limit our jumps to 15k, else we limit ourselves to whatever the ship layout is with a bit margin.
                        if (jump_distance > 15000)
                            jump_distance = 15000;
                    }else{
                        if (jump_distance > jump->max_distance - 2000)
                            jump_distance = jump->max_distance - 2000;
                    }
                    jump_distance += random(-1500, 1500);
                    JumpSystem::initializeJump(owner, jump_distance);
                }
            }
        }
        if (pathPlanner.route.size() > 1)
            keep_distance = 0.0;

        auto impulse = owner.getComponent<ImpulseEngine>();
        if (impulse && impulse->max_speed_forward > 0.0f) {
            if (distance > keep_distance + impulse->max_speed_forward * 5.0f)
                impulse->request = 1.0f;
            else
                impulse->request = (distance - keep_distance) / impulse->max_speed_forward * 5.0f;
            if (rotation_diff > 90)
                impulse->request = -impulse->request;
            else if (rotation_diff < 45)
                impulse->request *= 1.0f - ((rotation_diff - 45.0f) / 45.0f);
        }
    }
}

void ShipAI::flyFormation(sp::ecs::Entity target, glm::vec2 offset)
{
    auto ai = owner.getComponent<AIController>();
    if (!ai) return;
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return;
    auto tt = target.getComponent<sp::Transform>();
    if (!tt) return;
    auto target_position = tt->getPosition() + rotateVec2(ai->order_target_location, tt->getRotation());
    auto my_radius = 300.0f;
    if (auto physics = owner.getComponent<sp::Physics>()) my_radius = physics->getSize().x;
    pathPlanner.plan(my_radius, ot->getPosition(), target_position);

    auto impulse = owner.getComponent<ImpulseEngine>();
    if (!impulse) return;

    if (pathPlanner.route.size() == 1)
    {
        auto thrusters = owner.getComponent<ManeuveringThrusters>();
        auto docking_port = owner.getComponent<DockingPort>();
        if (docking_port && docking_port->state == DockingPort::State::Docked)
            DockingSystem::requestUndock(owner);
        else if (docking_port && docking_port->state == DockingPort::State::Docking)
            DockingSystem::abortDock(owner);

        auto diff = target_position - ot->getPosition();
        float distance = glm::length(diff);

        //Formation flying code
        float r = 100.0f;
        if (auto physics = owner.getComponent<sp::Physics>())
            r = physics->getSize().x * 5.0f;
        auto target_rotation = vec2ToAngle(diff);
        if (distance > r * 3)
        {
            flyTowards(target_position);
        }
        else if (distance > r)
        {
            float angle_diff = angleDifference(target_rotation, ot->getRotation());
            if (angle_diff > 10.0f)
                impulse->request = 0.0f;
            else if (angle_diff > 5.0f)
                impulse->request = (10.0f - angle_diff) / 5.0f;
            else
                impulse->request = 1.0f;
        }else{
            if (distance > r / 2.0f)
            {
                target_rotation += angleDifference(target_rotation, tt->getRotation()) * (1.0f - distance / r);
                impulse->request = distance / r;
            }else{
                target_rotation = tt->getRotation();
                impulse->request = 0.0f;
            }
        }
        if (thrusters) thrusters->target = target_rotation;
    }else{
        flyTowards(target_position);
    }
}

sp::ecs::Entity ShipAI::findBestTarget(glm::vec2 position, float radius)
{
    float target_score = 0.0;
    sp::ecs::Entity target;
    auto ot = owner.getComponent<sp::Transform>();
    auto owner_position = ot->getPosition();
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(radius, radius), position + glm::vec2(radius, radius)))
    {
        if (!entity.hasComponent<Hull>() || Faction::getRelation(owner, entity) != FactionRelation::Enemy || entity == target)
            continue;
        if (RadarBlockSystem::isRadarBlockedFrom(owner_position, entity, short_range))
            continue;
        float score = targetScore(entity);
        if (score == std::numeric_limits<float>::min())
            continue;
        if (!target || score > target_score)
        {
            target = entity;
            target_score = score;
        }
    }
    return target;
}

float ShipAI::targetScore(sp::ecs::Entity target)
{
    auto impulse = owner.getComponent<ImpulseEngine>();
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return std::numeric_limits<float>::min();
    auto tt = target.getComponent<sp::Transform>();
    if (!tt) return std::numeric_limits<float>::min();
    auto position_difference = tt->getPosition() - ot->getPosition();
    float distance = glm::length(position_difference);
    //auto position_difference_normal = position_difference / distance;
    //float rel_velocity = dot(target->getVelocity(), position_difference_normal) - dot(getVelocity(), position_difference_normal);
    float angle_difference = angleDifference(ot->getRotation(), vec2ToAngle(position_difference));
    auto thrusters = owner.getComponent<ManeuveringThrusters>();
    float score = -distance - std::abs(angle_difference / (thrusters ? thrusters->speed : 10.0f) * (impulse ? impulse->max_speed_forward : 0.0f)) * 1.5f;
    if (target.hasComponent<BeamWeaponSys>())
        score += 2500;
    if (target.hasComponent<MissileTubes>())
        score += 2500;
    if (target.hasComponent<DockingBay>())
        score -= 1500;
    if (target.hasComponent<AllowRadarLink>())
    {
        score -= 10000;
        if (distance > 5000)
            return std::numeric_limits<float>::min();
    }
    if (distance < 5000 && has_missiles)
        score += 500;

    if (distance < beam_weapon_range)
    {
        auto beamsystem = owner.getComponent<BeamWeaponSys>();
        if (beamsystem) {
            for(auto& mount : beamsystem->mounts) {
                if (distance < mount.range) {
                    if (fabs(angleDifference(angle_difference, mount.direction)) < mount.arc / 2.0f)
                        score += 1000;
                }
            }
        }
    }
    return score;
}

bool ShipAI::betterTarget(sp::ecs::Entity new_target, sp::ecs::Entity current_target)
{
    float new_score = targetScore(new_target);
    float current_score = targetScore(current_target);

    // Ignore targets if their score is the lowest possible value.
    if (new_score == std::numeric_limits<float>::min())
        return false;
    if (current_score == std::numeric_limits<float>::min())
        return true;
    if (new_score > current_score * 1.5f)
        return true;
    if (new_score > current_score + 5000.0f)
        return true;
    return false;
}

float ShipAI::calculateFiringSolution(sp::ecs::Entity target, const MissileTubes::MountPoint& tube)
{
    // Never fire missiles at scan probes.
    if (target.hasComponent<MoveTo>() && target.hasComponent<ShareShortRangeRadar>())
        return std::numeric_limits<float>::infinity();
    auto tt = target.getComponent<sp::Transform>();
    if (!tt) return std::numeric_limits<float>::infinity();
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return std::numeric_limits<float>::infinity();

    EMissileWeapons type = tube.type_loaded;

    // Search if a non-enemy ship might be damaged by a missile attack on a
    // line of fire within our short-range radar range.
    auto target_position = tt->getPosition();
    const float target_distance = glm::length(ot->getPosition() - target_position);
    const float search_distance = std::min(short_range, target_distance + 500.0f);
    const float target_angle = vec2ToAngle(target_position - ot->getPosition());
    const float search_angle = 5.0;

    // Verify if missle can be fired safely
    for(auto entity : sp::CollisionSystem::queryArea(ot->getPosition() - glm::vec2(search_distance, search_distance), ot->getPosition() + glm::vec2(search_distance, search_distance)))
    {
        if (Faction::getRelation(owner, entity) != FactionRelation::Enemy && entity.hasComponent<Hull>() && (entity.hasComponent<ImpulseEngine>() || entity.hasComponent<DockingBay>()))
        {
            if (auto t = entity.getComponent<sp::Transform>()) {
                // Ship in research triangle
                const auto owner_to_obj = t->getPosition() - ot->getPosition();
                const float heading_to_obj = vec2ToAngle(owner_to_obj);
                const float angle_from_heading_to_target = std::abs(angleDifference(heading_to_obj, target_angle));
                if (angle_from_heading_to_target < search_angle) {
                    return std::numeric_limits<float>::infinity();
                }
            }
        }
    }

    if (type == MW_HVLI)    //Custom HVLI targeting for AI, as the calculate firing solution
    {
        const MissileWeaponData& data = MissileWeaponData::getDataFor(type);

        auto target_position = tt->getPosition();
        float target_angle = vec2ToAngle(target_position - ot->getPosition());
        float fire_angle = ot->getRotation() + tube.direction;

        //HVLI missiles do not home or turn. So use a different targeting mechanism.
        float angle_diff = angleDifference(target_angle, fire_angle);

        //Target is moving. Estimate where he will be when the missile hits.
        float fly_time = target_distance / data.speed;
        if (auto physics = target.getComponent<sp::Physics>())
            target_position += physics->getVelocity() * fly_time;

        //If our "error" of hitting is less then double the radius of the target, fire.
        auto target_radius = 100.0f;
        if (auto physics = target.getComponent<sp::Physics>())
            target_radius = physics->getSize().x;
        if (std::abs(angle_diff) < 80.0f && target_distance * glm::degrees(tanf(fabs(angle_diff))) < target_radius * 2.0f)
            return fire_angle;

        return std::numeric_limits<float>::infinity();
    }

    if (type == MW_Nuke || type == MW_EMP)
    {
        auto target_position = tt->getPosition();

        //Check if we can sort of safely fire an Nuke/EMP. The target needs to be clear of friendly/neutrals.
        float safety_radius = 1100;
        if (glm::length2(target_position - ot->getPosition()) < safety_radius*safety_radius)
            return std::numeric_limits<float>::infinity();
        for(auto entity : sp::CollisionSystem::queryArea(tt->getPosition() - glm::vec2(safety_radius, safety_radius), tt->getPosition() + glm::vec2(safety_radius, safety_radius)))
        {
            if (Faction::getRelation(owner, entity) != FactionRelation::Enemy && entity.hasComponent<Hull>() && (entity.hasComponent<DockingBay>() || entity.getComponent<DockingPort>()))
            {
                auto physics = entity.getComponent<sp::Physics>();
                auto et = entity.getComponent<sp::Transform>();
                if (physics && et && glm::length(et->getPosition() - ot->getPosition()) < safety_radius - physics->getSize().x)
                {
                    return std::numeric_limits<float>::infinity();
                }
            }
        }
    }

    //Use the general weapon tube targeting to get the final firing solution.
    return MissileSystem::calculateFiringSolution(owner, tube, target);
}

sp::ecs::Entity ShipAI::findBestMissileRestockTarget(glm::vec2 position, float radius)
{
    auto port = owner.getComponent<DockingPort>();
    if (!port)
        return {};
    // Check each object within the given radius. If it's friendly, we can dock
    // to it, and it can restock our missiles, then select it.
    float target_score = 0.0;
    sp::ecs::Entity target;
    auto owner_transform = owner.getComponent<sp::Transform>();
    if (!owner_transform)
        return {};
    auto owner_position = owner_transform->getPosition();
    for(auto [entity, dockingbay, transform, impulse] : sp::ecs::Query<DockingBay, sp::Transform, ImpulseEngine>())
    {
        if (Faction::getRelation(owner, entity) != FactionRelation::Friendly)
            continue;
        if (port->canDockOn(dockingbay) == DockingStyle::None || !(dockingbay.flags & DockingBay::RestockMissiles))
            continue;
        //calculate score
        auto position_difference = transform.getPosition() - owner_position;
        float distance = glm::length(position_difference);
        float angle_difference = angleDifference(owner_transform->getRotation(), vec2ToAngle(position_difference));
        auto thrusters = owner.getComponent<ManeuveringThrusters>();
        float score = -distance - std::abs(angle_difference / (thrusters ? thrusters->speed : 10.0f) * impulse.max_speed_forward) * 1.5f;
        if (entity.hasComponent<ImpulseEngine>())
        {
            score -= 5000;
        }
        if (score == std::numeric_limits<float>::min())
            continue;
        if (!target || score > target_score)
        {
            target = entity;
            target_score = score;
        }
    }
    return target;
}
