#include "spaceObjects/nebula.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/scanProbe.h"
#include "ai/ai.h"
#include "ai/aiFactory.h"
#include "random.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/hull.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "systems/collision.h"
#include "systems/jumpsystem.h"
#include "systems/docking.h"
#include "systems/missilesystem.h"
#include "ecs/query.h"


REGISTER_SHIP_AI(ShipAI, "default");

ShipAI::ShipAI(CpuShip* owner)
: pathPlanner(owner->getRadius()), owner(owner)
{
    missile_fire_delay = 0.0;

    has_missiles = false;
    has_beams = false;
    beam_weapon_range = 0.0;
    weapon_direction = EWeaponDirection::Front;

    update_target_delay = 0.0;

    short_range = owner->getShortRangeRadarRange();
    long_range = owner->getLongRangeRadarRange();
    relay_range = long_range * 2.0f;
}

bool ShipAI::canSwitchAI()
{
    return true;
}

void ShipAI::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 draw_position, float scale)
{
    auto world_position = owner->getPosition();
    P<SpaceObject> target = owner->getTarget();
    if (target)
    {
        auto v = target->getPosition() - world_position;
        renderer.drawLine(draw_position, draw_position + v * scale, glm::u8vec4(255, 128, 128, 64));
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
    auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
    if (thrusters) thrusters->stop();

    auto impulse = owner->entity.getComponent<ImpulseEngine>();
    if (impulse)
        impulse->request = 0.0f;
    auto warp = owner->entity.getComponent<WarpDrive>();
    if (warp)
        warp->request = 0;

    updateWeaponState(delta);
    if (update_target_delay > 0.0f)
    {
        update_target_delay -= delta;
    }else{
        update_target_delay = random(0.25, 0.5);
        updateTarget();
    }

    //If we have a target and weapons, engage the target.
    if (owner->getTarget() && (has_missiles || has_beams))
    {
        runAttack(owner->getTarget());
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
    auto tubes = owner->entity.getComponent<MissileTubes>();
    if (tubes) {
        for(int n=0; n<tubes->count; n++)
        {
            auto& tube = tubes->mounts[n];
            if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_EMP] > 0 && tube.canLoad(MW_EMP))
                MissileSystem::startLoad(owner->entity, tube, MW_EMP);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_Nuke] > 0 && tube.canLoad(MW_Nuke))
                MissileSystem::startLoad(owner->entity, tube, MW_Nuke);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_Homing] > 0 && tube.canLoad(MW_Homing))
                MissileSystem::startLoad(owner->entity, tube, MW_Homing);
            else if (tube.state == MissileTubes::MountPoint::State::Empty && tubes->storage[MW_HVLI] > 0 && tube.canLoad(MW_HVLI))
                MissileSystem::startLoad(owner->entity, tube, MW_HVLI);

            //When the tube is loading or loaded, add the relative strenght of this tube to the direction of this tube.
            if (tube.state == MissileTubes::MountPoint::State::Loading || tube.state == MissileTubes::MountPoint::State::Loaded)
            {
                int index = getDirectionIndex(tube.direction, 90);
                if (index >= 0)
                    tube_strength_per_direction[index] += getMissileWeaponStrength(tube.type_loaded) / tube.load_time;
            }
        }
    }

    auto beamsystem = owner->entity.getComponent<BeamWeaponSys>();
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
        for(int n=0; n<tubes->count; n++)
        {
            auto& tube = tubes->mounts[n];
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
    P<SpaceObject> target = owner->getTarget();
    P<SpaceObject> new_target;
    auto position = owner->getPosition();
    EAIOrder orders = owner->getOrder();
    auto order_target_location = owner->getOrderTargetLocation();
    P<SpaceObject> order_target = owner->getOrderTarget();
    // Update ranges before calculating
    short_range = owner->getShortRangeRadarRange();
    long_range = owner->getLongRangeRadarRange();

    // Check if we lost our target because it entered a nebula.
    if (target && target->canHideInNebula() && Nebula::blockedByNebula(position, target->getPosition(), owner->getShortRangeRadarRange()))
    {
        // When we're roaming, and we lost our target in a nebula, set the
        // "fly to" position to the last known position of the enemy target.
        if (orders == AI_Roaming)
        {
            owner->orderRoamingAt(target->getPosition());
        }

        target = NULL;
    }

    // If the target is no longer an enemy, clear the target.
    if (target && !owner->isEnemy(target))
        target = NULL;

    // If we're roaming, select the best target within long-range radar range.
    if (orders == AI_Roaming)
    {
        if (target)
            new_target = findBestTarget(position, short_range + 2000.0f);
        else
            new_target = findBestTarget(position, long_range);
    }

    // If we're holding ground or flying toward a destination, select only
    // targets within 2U of our short-range radar range.
    if (orders == AI_StandGround || orders == AI_FlyTowards)
    {
        new_target = findBestTarget(position, short_range + 2000.0f);
    }

    // If we're defending a position, select only targets within 2U of our
    // short-range radar range.
    if (orders == AI_DefendLocation)
    {
        new_target = findBestTarget(order_target_location, short_range + 2000.0f);
    }

    // If we're flying in formation, select targets only within short-range
    // radar range.
    if (orders == AI_FlyFormation && order_target)
    {
        P<SpaceShip> ship = order_target;

        if (ship && ship->getTarget() && glm::length2(ship->getTarget()->getPosition() - position) < short_range*short_range)
        {
            new_target = ship->getTarget();
        }
    }

    // If we're defending a target, select only targets within 2U of our
    // short-range radar range.
    if (orders == AI_DefendTarget)
    {
        if (order_target)
        {
            new_target = findBestTarget(order_target->getPosition(), short_range + 2000.0f);
        }
    }

    if (orders == AI_Attack)
    {
        new_target = order_target;
    }

    // Check if we need to drop the current target.
    if (target)
    {
        float target_distance = glm::length(target->getPosition() - position);

        // Release the target if it moves more than short-range radar range +
        // 3U away from us or our destination.
        if ((orders == AI_StandGround
            || orders == AI_DefendLocation
            || orders == AI_DefendTarget
            || orders == AI_FlyTowards) && (target_distance > short_range + 3000.0f))
        {
            target = NULL;
        }

        // If we're flying in formation, release the target if it moves more
        // than short-range radar range + 1U away from us.
        if (orders == AI_FlyFormation && target_distance > short_range + 1000.0f)
        {
            target = NULL;
        }

        // Don't target anything if we're idling, flying blind, or docking.
        if (orders == AI_Idle
            || orders == AI_FlyTowardsBlind
            || orders == AI_Dock)
        {
            target = NULL;
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
        owner->target_id = -1;
    }
    // Otherwise, set the new target on the owner.
    else
    {
        owner->target_id = target->getMultiplayerId();
    }
}

void ShipAI::runOrders()
{
    // Update ranges before calculating
    long_range = owner->getLongRangeRadarRange();
    relay_range = long_range * 2.0f;
    auto docking_port = owner->entity.getComponent<DockingPort>();

    //When we are not attacking a target, follow orders
    switch(owner->getOrder())
    {
    case AI_Idle:            //Don't do anything, don't even attack.
        pathPlanner.clear();
        break;
    case AI_Roaming:         //Fly around and engage at will, without a clear target
        //Could mean 3 things
        // 1) we are looking for a target
        // 2) we ran out of missiles
        // 3) we have no weapons
        if (has_missiles || has_beams)
        {
            P<SpaceObject> new_target = findBestTarget(owner->getPosition(), relay_range);
            if (new_target)
            {
                owner->target_id = new_target->getMultiplayerId();
            }else{
                auto diff = owner->getOrderTargetLocation() - owner->getPosition();
                if (glm::length2(diff) < 1000.0f*1000.0f)
                    owner->orderRoamingAt(glm::vec2(random(-long_range, long_range), random(-long_range, long_range)));
                flyTowards(owner->getOrderTargetLocation());
            }
        }else{
            auto tubes = owner->entity.getComponent<MissileTubes>();
            if (tubes && tubes->count > 0)
            {
                // Find a station which can re-stock our weapons.
                P<SpaceObject> new_target = findBestMissileRestockTarget(owner->getPosition(), long_range);
                if (new_target)
                {
                    owner->orderRetreat(new_target);
                }else{
                    auto diff = owner->getOrderTargetLocation() - owner->getPosition();
                    if (glm::length2(diff) < 1000.0f*1000.0f)
                        owner->orderRoamingAt(glm::vec2(random(-long_range, long_range), random(-long_range, long_range)));
                    flyTowards(owner->getOrderTargetLocation());
                }
            }else{
                pathPlanner.clear();
            }
        }
        break;
    case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
        pathPlanner.clear();
        break;
    case AI_FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
    case AI_FlyTowardsBlind: //Fly towards [order_target_location], not attacking anything
        flyTowards(owner->getOrderTargetLocation());
        if (glm::length2(owner->getPosition() - owner->getOrderTargetLocation()) < owner->getRadius()*owner->getRadius())
        {
            if (owner->getOrder() == AI_FlyTowards)
                owner->orderDefendLocation(owner->getOrderTargetLocation());
            else
                owner->orderIdle();
        }
        break;
    case AI_DefendLocation:  //Defend against enemies getting close to [order_target_location]
        {
            glm::vec2 target_position = owner->getOrderTargetLocation();
            target_position += vec2FromAngle(vec2ToAngle(target_position - owner->getPosition()) + 170.0f) * 1500.0f;
            flyTowards(target_position);
        }
        break;
    case AI_DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
        if (owner->getOrderTarget())
        {
            auto target_position = owner->getOrderTarget()->getPosition();
            float circle_distance = 2000.0f + owner->getOrderTarget()->getRadius() * 2.0f + owner->getRadius() * 2.0f;
            target_position += vec2FromAngle(vec2ToAngle(target_position - owner->getPosition()) + 170.0f) * circle_distance;
            flyTowards(target_position);
        }else{
            owner->orderRoaming();    //We pretty much lost our defending target, so just start roaming.
        }
        break;
    case AI_FlyFormation:    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
        if (owner->getOrderTarget())
        {
            flyFormation(owner->getOrderTarget(), owner->getOrderTargetLocation());
        }else{
            owner->orderRoaming();
        }
        break;
    case AI_Attack:          //Attack [order_target] very specificly.
        pathPlanner.clear();
        break;
    case AI_Retreat:
        if ((docking_port && docking_port->state == DockingPort::State::Docked && docking_port->target) && (owner->getOrderTarget()) && P<ShipTemplateBasedObject>(owner->getOrderTarget()))
        {
            auto bay = docking_port->target.getComponent<DockingBay>();
            bool allow_undock = true;
            if (bay) {
                if (bay->flags & DockingBay::RestockMissiles)
                {
                    auto tubes = owner->entity.getComponent<MissileTubes>();
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
                    auto hull = owner->entity.getComponent<Hull>();
                    if (hull && hull->current < hull->max)
                        allow_undock = false;
                }
            }
            if (allow_undock)
            {
                owner->orderRoaming();    //deletes order_target
                break;
            }
        }else{
            P<SpaceObject> new_target = findBestMissileRestockTarget(owner->getPosition(), relay_range);
            if (new_target)
            {
                owner->orderRetreat(new_target);
            }
        }
        [[fallthrough]]; // continue with docking or roaming
    case AI_Dock:            //Dock with [order_target]
        if (owner->getOrderTarget() && docking_port)
        {
            if (docking_port->state == DockingPort::State::NotDocking || docking_port->target != owner->getOrderTarget()->entity)
            {
                auto target_position = owner->getOrderTarget()->getPosition();
                auto diff = owner->getPosition() - target_position;
                float dist = glm::length(diff);
                if (dist < 600 + owner->getOrderTarget()->getRadius())
                {
                    DockingSystem::requestDock(owner->entity, owner->getOrderTarget()->entity);
                }else{
                    target_position += (diff / dist) * 500.0f;
                    flyTowards(target_position);
                }
            }
        }else{
            owner->orderRoaming();  //Nothing to dock, just fall back to roaming.
        }
        break;
    }
}

void ShipAI::runAttack(P<SpaceObject> target)
{
    float attack_distance = 4000.0;
    if (has_missiles && best_missile_type == MW_HVLI)
        attack_distance = 2500.0;
    if (has_beams)
        attack_distance = beam_weapon_range * 0.7f;

    auto position_diff = target->getPosition() - owner->getPosition();
    float distance = glm::length(position_diff);

    // missile attack
    if (distance < 4500 && has_missiles)
    {
        auto tubes = owner->entity.getComponent<MissileTubes>();
        for(int n=0; tubes && n<tubes->count; n++)
        {
            if (tubes->mounts[n].state == MissileTubes::MountPoint::State::Loaded && missile_fire_delay <= 0.0f)
            {
                float target_angle = calculateFiringSolution(target, tubes->mounts[n]);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    MissileSystem::fire(owner->entity, tubes->mounts[n], target_angle, target->entity);
                    missile_fire_delay = tubes->mounts[n].load_time / tubes->count / 2.0f;
                }
            }
        }
    }

    if (owner->getOrder() == AI_StandGround)
    {
        auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
        if (thrusters) thrusters->target = vec2ToAngle(position_diff);
    }else{
        if (weapon_direction == EWeaponDirection::Side || weapon_direction == EWeaponDirection::Left || weapon_direction == EWeaponDirection::Right)
        {
            //We have side beams, find out where we want to attack from.
            auto target_position = target->getPosition();
            auto diff = target_position - owner->getPosition();
            float angle = vec2ToAngle(diff);
            if ((weapon_direction == EWeaponDirection::Side && angleDifference(angle, owner->getRotation()) > 0) || weapon_direction == EWeaponDirection::Left)
                angle += 160;
            else
                angle -= 160;
            target_position += vec2FromAngle(angle) * (attack_distance + target->getRadius());
            flyTowards(target_position, 0);
        }else{
            flyTowards(target->getPosition(), attack_distance);
        }
    }
}

void ShipAI::flyTowards(glm::vec2 target, float keep_distance)
{
    pathPlanner.plan(owner->getPosition(), target);

    if (pathPlanner.route.size() > 0)
    {
        auto docking_port = owner->entity.getComponent<DockingPort>();
        if (docking_port && docking_port->state == DockingPort::State::Docked)
            DockingSystem::requestUndock(owner->entity);

        auto diff = pathPlanner.route[0] - owner->getPosition();
        float distance = glm::length(diff);

        //Normal flying towards target code
        auto target_rotation = vec2ToAngle(diff);
        auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
        if (thrusters) thrusters->target = target_rotation;
        float rotation_diff = fabs(angleDifference(target_rotation, owner->getRotation()));

        auto warp = owner->entity.getComponent<WarpDrive>();
        if (warp && rotation_diff < 30.0f && distance > 2000.0f)
        {
            warp->request = 1.0;
        }else{
            warp->request = 0.0;
        }
        auto jump = owner->entity.getComponent<JumpDrive>();
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
                JumpSystem::initializeJump(owner->entity, jump_distance);
            }
        }
        if (pathPlanner.route.size() > 1)
            keep_distance = 0.0;

        auto impulse = owner->entity.getComponent<ImpulseEngine>();
        if (impulse) {
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

void ShipAI::flyFormation(P<SpaceObject> target, glm::vec2 offset)
{
    auto target_position = target->getPosition() + rotateVec2(owner->getOrderTargetLocation(), target->getRotation());
    pathPlanner.plan(owner->getPosition(), target_position);

    auto impulse = owner->entity.getComponent<ImpulseEngine>();
    if (!impulse) return;

    if (pathPlanner.route.size() == 1)
    {
        auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
        auto docking_port = owner->entity.getComponent<DockingPort>();
        if (docking_port && docking_port->state == DockingPort::State::Docked)
            DockingSystem::requestUndock(owner->entity);

        auto diff = target_position - owner->getPosition();
        float distance = glm::length(diff);

        //Formation flying code
        float r = owner->getRadius() * 5.0f;
        auto target_rotation = vec2ToAngle(diff);
        if (distance > r * 3)
        {
            flyTowards(target_position);
        }
        else if (distance > r)
        {
            float angle_diff = angleDifference(target_rotation, owner->getRotation());
            if (angle_diff > 10.0f)
                impulse->request = 0.0f;
            else if (angle_diff > 5.0f)
                impulse->request = (10.0f - angle_diff) / 5.0f;
            else
                impulse->request = 1.0f;
        }else{
            if (distance > r / 2.0f)
            {
                target_rotation += angleDifference(target_rotation, target->getRotation()) * (1.0f - distance / r);
                impulse->request = distance / r;
            }else{
                target_rotation = target->getRotation();
                impulse->request = 0.0f;
            }
        }
        if (thrusters) thrusters->target = target_rotation;
    }else{
        flyTowards(target_position);
    }
}

P<SpaceObject> ShipAI::findBestTarget(glm::vec2 position, float radius)
{
    float target_score = 0.0;
    P<SpaceObject> target;
    auto owner_position = owner->getPosition();
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(radius, radius), position + glm::vec2(radius, radius)))
    {
        auto ptr = entity.getComponent<SpaceObject*>();
        if (!ptr || !*ptr) continue;
        P<SpaceObject> space_object = *ptr;
        if (!space_object || !space_object->canBeTargetedBy(owner) || !owner->isEnemy(space_object) || space_object == target)
            continue;
        if (space_object->canHideInNebula() && Nebula::blockedByNebula(owner_position, space_object->getPosition(), owner->getShortRangeRadarRange()))
            continue;
        float score = targetScore(space_object);
        if (score == std::numeric_limits<float>::min())
            continue;
        if (!target || score > target_score)
        {
            target = space_object;
            target_score = score;
        }
    }
    return target;
}

float ShipAI::targetScore(P<SpaceObject> target)
{
    auto impulse = owner->entity.getComponent<ImpulseEngine>();
    auto position_difference = target->getPosition() - owner->getPosition();
    float distance = glm::length(position_difference);
    //auto position_difference_normal = position_difference / distance;
    //float rel_velocity = dot(target->getVelocity(), position_difference_normal) - dot(getVelocity(), position_difference_normal);
    float angle_difference = angleDifference(owner->getRotation(), vec2ToAngle(position_difference));
    auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
    float score = -distance - std::abs(angle_difference / (thrusters ? thrusters->speed : 10.0f) * (impulse ? impulse->max_speed_forward : 0.0f)) * 1.5f;
    if (P<SpaceStation>(target))
    {
        score -= 5000;
    }
    if (P<ScanProbe>(target))
    {
        score -= 10000;
        if (distance > 5000)
            return std::numeric_limits<float>::min();
    }
    if (distance < 5000 && has_missiles)
        score += 500;

    if (distance < beam_weapon_range)
    {
        auto beamsystem = owner->entity.getComponent<BeamWeaponSys>();
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

bool ShipAI::betterTarget(P<SpaceObject> new_target, P<SpaceObject> current_target)
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

float ShipAI::calculateFiringSolution(P<SpaceObject> target, const MissileTubes::MountPoint& tube)
{
    // Update ranges before calculating
    short_range = owner->getShortRangeRadarRange();

    // Never fire missiles at scan probes.
    if (P<ScanProbe>(target))
    {
        return std::numeric_limits<float>::infinity();
    }

    EMissileWeapons type = tube.type_loaded;

    // Search if a non-enemy ship might be damaged by a missile attack on a
    // line of fire within our short-range radar range.
    auto target_position = target->getPosition();
    const float target_distance = glm::length(owner->getPosition() - target_position);
    const float search_distance = std::min(short_range, target_distance + 500.0f);
    const float target_angle = vec2ToAngle(target_position - owner->getPosition());
    const float search_angle = 5.0;

    // Verify if missle can be fired safely
    for(auto entity : sp::CollisionSystem::queryArea(owner->getPosition() - glm::vec2(search_distance, search_distance), owner->getPosition() + glm::vec2(search_distance, search_distance)))
    {
        auto ptr = entity.getComponent<SpaceObject*>();
        if (!ptr || !*ptr) continue;
        P<SpaceObject> obj = *ptr;
        if (obj && !obj->isEnemy(owner) && (P<SpaceShip>(obj) || P<SpaceStation>(obj)))
        {
            // Ship in research triangle
            const auto owner_to_obj = obj->getPosition() - owner->getPosition();
            const float heading_to_obj = vec2ToAngle(owner_to_obj);
            const float angle_from_heading_to_target = std::abs(angleDifference(heading_to_obj, target_angle));
            if(angle_from_heading_to_target < search_angle){
              return std::numeric_limits<float>::infinity();
            }
        }
    }

    if (type == MW_HVLI)    //Custom HVLI targeting for AI, as the calculate firing solution
    {
        const MissileWeaponData& data = MissileWeaponData::getDataFor(type);

        auto target_position = target->getPosition();
        float target_angle = vec2ToAngle(target_position - owner->getPosition());
        float fire_angle = owner->getRotation() + tube.direction;

        //HVLI missiles do not home or turn. So use a different targeting mechanism.
        float angle_diff = angleDifference(target_angle, fire_angle);

        //Target is moving. Estimate where he will be when the missile hits.
        float fly_time = target_distance / data.speed;
        target_position += target->getVelocity() * fly_time;

        //If our "error" of hitting is less then double the radius of the target, fire.
        if (std::abs(angle_diff) < 80.0f && target_distance * glm::degrees(tanf(fabs(angle_diff))) < target->getRadius() * 2.0f)
            return fire_angle;

        return std::numeric_limits<float>::infinity();
    }

    if (type == MW_Nuke || type == MW_EMP)
    {
        auto target_position = target->getPosition();

        //Check if we can sort of safely fire an Nuke/EMP. The target needs to be clear of friendly/neutrals.
        float safety_radius = 1100;
        if (glm::length2(target_position - owner->getPosition()) < safety_radius*safety_radius)
            return std::numeric_limits<float>::infinity();
        for(auto entity : sp::CollisionSystem::queryArea(target->getPosition() - glm::vec2(safety_radius, safety_radius), target->getPosition() + glm::vec2(safety_radius, safety_radius)))
        {
            auto ptr = entity.getComponent<SpaceObject*>();
            if (!ptr || !*ptr) continue;
            P<SpaceObject> obj = *ptr;
            if (obj && !obj->isEnemy(owner) && (P<SpaceShip>(obj) || P<SpaceStation>(obj)))
            {
                if (glm::length(obj->getPosition() - owner->getPosition()) < safety_radius - obj->getRadius())
                {
                    return std::numeric_limits<float>::infinity();
                }
            }
        }
    }

    //Use the general weapon tube targeting to get the final firing solution.
    return MissileSystem::calculateFiringSolution(owner->entity, tube, target->entity);
}

P<SpaceObject> ShipAI::findBestMissileRestockTarget(glm::vec2 position, float radius)
{
    auto port = owner->entity.getComponent<DockingPort>();
    if (!port)
        return nullptr;
    // Check each object within the given radius. If it's friendly, we can dock
    // to it, and it can restock our missiles, then select it.
    float target_score = 0.0;
    P<SpaceObject> target;
    auto owner_position = owner->getPosition();
    for(auto [entity, dockingbay, impulse, obj] : sp::ecs::Query<DockingBay, ImpulseEngine, SpaceObject*>())
    {
        if (!obj || !owner->isFriendly(obj) || obj == *target)
            continue;
        if (port->canDockOn(dockingbay) == DockingStyle::None || !(dockingbay.flags & DockingBay::RestockMissiles))
            continue;
        //calculate score
        auto position_difference = obj->getPosition() - owner_position;
        float distance = glm::length(position_difference);
        float angle_difference = angleDifference(owner->getRotation(), vec2ToAngle(position_difference));
        auto thrusters = owner->entity.getComponent<ManeuveringThrusters>();
        float score = -distance - std::abs(angle_difference / (thrusters ? thrusters->speed : 10.0f) * impulse.max_speed_forward) * 1.5f;
        if (P<SpaceShip>(P<SpaceObject>(obj)))
        {
            score -= 5000;
        }
        if (score == std::numeric_limits<float>::min())
            continue;
        if (!target || score > target_score)
        {
            target = obj;
            target_score = score;
        }
    }
    return target;
}
