#include "spaceObjects/nebula.h"
#include "spaceObjects/cpuShip.h"
#include "ai/ai.h"
#include "ai/aiFactory.h"

REGISTER_SHIP_AI(ShipAI, "default");

ShipAI::ShipAI(CpuShip* owner)
: owner(owner)
{
    missile_fire_delay = 0.0;

    has_missiles = false;
    has_beams = false;
    beam_weapon_range = 0.0;
    
    update_target_delay = 0.0;
}

ShipAI::~ShipAI()
{
}

bool ShipAI::canSwitchAI()
{
    return true;
}

void ShipAI::run(float delta)
{
    owner->target_rotation = owner->getRotation();
    owner->warp_request = 0.0;
    owner->impulse_request = 0.0f;

    updateWeaponState(delta);
    if (update_target_delay > 0.0)
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

void ShipAI::updateWeaponState(float delta)
{
    if (missile_fire_delay > 0.0)
        missile_fire_delay -= delta;

    //Check the weapon state,
    has_missiles = owner->weapon_tubes > 0 && owner->weapon_storage[MW_Homing] > 0;
    has_beams = false;
    //If we have weapon tubes, load them with torpedoes
    for(int n=0; n<owner->weapon_tubes; n++)
    {
        if (owner->weaponTube[n].state == WTS_Empty && owner->weapon_storage[MW_Homing] > 0)
            owner->loadTube(n, MW_Homing);
        if (owner->weaponTube[n].state == WTS_Loaded && owner->weaponTube[n].type_loaded == MW_Homing)
            has_missiles = true;
    }

    beam_weapon_range = 0;
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (owner->beam_weapons[n].range > 0)
        {
            if (sf::angleDifference(owner->beam_weapons[n].direction, 0.0f) < owner->beam_weapons[n].arc / 2.0f)
            {
                beam_weapon_range = std::max(beam_weapon_range, owner->beam_weapons[n].range);
            }
            has_beams = true;
            break;
        }
    }
}

void ShipAI::updateTarget()
{
    P<SpaceObject> target = owner->getTarget();
    P<SpaceObject> new_target;
    sf::Vector2f position = owner->getPosition();
    EAIOrder orders = owner->getOrder();
    sf::Vector2f order_target_location = owner->getOrderTargetLocation();
    P<SpaceObject> order_target = owner->getOrderTarget();

    //Check if we need to lose our target because it entered a nebula.
    if (target && target->canHideInNebula() && (target->getPosition() - position) > 5000.0f && Nebula::blockedByNebula(position, target->getPosition()))
    {
        //When we are roaming, and we lost our target in a nebula, set the "fly to" position to the last known position of the enemy ship.
        if (orders == AI_Roaming)
            owner->orderRoamingAt(target->getPosition());
        target = NULL;
    }
    if (target && !owner->isEnemy(target))
        target = NULL;

    //Find new target which we might switch to
    if (orders == AI_Roaming)
        new_target = findBestTarget(position, 8000);
    if (orders == AI_StandGround || orders == AI_FlyTowards)
        new_target = findBestTarget(position, 7000);
    if (orders == AI_DefendLocation)
        new_target = findBestTarget(order_target_location, 7000);
    if (orders == AI_FlyFormation && order_target)
    {
        P<SpaceShip> ship = order_target;
        if (ship && ship->getTarget() && (ship->getTarget()->getPosition() - position) < 5000.0f)
            new_target = ship->getTarget();
    }
    if (orders == AI_DefendTarget)
    {
        if (order_target)
            new_target = findBestTarget(order_target->getPosition(), 7000);
    }
    if (orders == AI_Attack)
        new_target = order_target;

    //Check if we need to drop the current target
    if (target)
    {
        float target_distance = sf::length(target->getPosition() - position);
        if (orders == AI_Idle)
            target = NULL;
        if (orders == AI_StandGround && target_distance > 8000)
            target = NULL;
        if (orders == AI_DefendLocation && target_distance > 8000)
            target = NULL;
        if (orders == AI_DefendTarget && target_distance > 8000)
            target = NULL;
        if (orders == AI_FlyTowards && target_distance > 8000)
            target = NULL;
        if (orders == AI_FlyTowardsBlind)
            target = NULL;
        if (orders == AI_FlyFormation && target_distance > 6000)
            target = NULL;
        if (orders == AI_Dock)
            target = NULL;
    }

    //Check if we want to switch to a new target
    if (new_target)
    {
        if (!target || betterTarget(new_target, target))
        {
            target = new_target;
        }
    }
    if (!target)
        owner->target_id = -1;
    else
        owner->target_id = target->getMultiplayerId();
}

void ShipAI::runOrders()
{
    //When we are not attacking a target, follow orders
    switch(owner->getOrder())
    {
    case AI_Idle:            //Don't do anything, don't even attack.
        break;
    case AI_Roaming:         //Fly around and engage at will, without a clear target
        //Could mean 3 things
        // 1) we are looking for a target
        // 2) we ran out of missiles
        // 3) we have no weapons
        if (has_missiles || has_beams)
        {
            P<SpaceObject> new_target = findBestTarget(owner->getPosition(), 50000);
            if (new_target)
            {
                owner->target_id = new_target->getMultiplayerId();
            }else{
                sf::Vector2f diff = owner->getOrderTargetLocation() - owner->getPosition();
                if (diff < 1000.0f)
                    owner->orderRoamingAt(sf::Vector2f(random(-30000, 30000), random(-30000, 30000)));
                flyTowards(owner->getOrderTargetLocation());
            }
        }else{
            //TODO: Find someething which can re-stock our weapons.
        }
        break;
    case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
        break;
    case AI_FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
    case AI_FlyTowardsBlind: //Fly towards [order_target_location], not attacking anything
        flyTowards(owner->getOrderTargetLocation());
        if ((owner->getPosition() - owner->getOrderTargetLocation()) < owner->getRadius())
        {
            if (owner->getOrder() == AI_FlyTowards)
                owner->orderDefendLocation(owner->getOrderTargetLocation());
            else
                owner->orderIdle();
        }
        break;
    case AI_DefendLocation:  //Defend against enemies getting close to [order_target_location]
        {
            sf::Vector2f target_position = owner->getOrderTargetLocation();
            target_position += sf::vector2FromAngle(sf::vector2ToAngle(target_position - owner->getPosition()) + 170.0f) * 1500.0f;
            flyTowards(target_position);
        }
        break;
    case AI_DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
        if (owner->getOrderTarget())
        {
            sf::Vector2f target_position = owner->getOrderTarget()->getPosition();
            float circle_distance = 2000.0f + owner->getOrderTarget()->getRadius() * 2.0 + owner->getRadius() * 2.0;
            target_position += sf::vector2FromAngle(sf::vector2ToAngle(target_position - owner->getPosition()) + 170.0f) * circle_distance;
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
    case AI_Dock:            //Dock with [order_target]
        if (owner->getOrderTarget())
        {
            if (owner->docking_state == DS_NotDocking || owner->docking_target != owner->getOrderTarget())
            {
                sf::Vector2f target_position = owner->getOrderTarget()->getPosition();
                sf::Vector2f diff = owner->getPosition() - target_position;
                float dist = sf::length(diff);
                if (dist < 600 + owner->getOrderTarget()->getRadius())
                {
                    owner->requestDock(owner->getOrderTarget());
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
    if (has_beams)
        attack_distance = beam_weapon_range * 0.7;

    sf::Vector2f position_diff = target->getPosition() - owner->getPosition();
    float distance = sf::length(position_diff);

    if (distance < 4500 && has_missiles)
    {
        for(int n=0; n<owner->weapon_tubes; n++)
        {
            if (owner->weaponTube[n].state == WTS_Loaded && missile_fire_delay <= 0.0)
            {
                float target_angle = calculateFiringSolution(target);
                if (target_angle != std::numeric_limits<float>::infinity())
                    owner->fireTube(n, target_angle);
                missile_fire_delay = owner->tube_load_time / owner->weapon_tubes / 2.0;
            }
        }
    }

    if (owner->getOrder() == AI_StandGround)
    {
        owner->target_rotation = sf::vector2ToAngle(position_diff);
    }else{
        flyTowards(target->getPosition(), attack_distance);
    }
}

void ShipAI::flyTowards(sf::Vector2f target, float keep_distance)
{
    pathPlanner.plan(owner->getPosition(), target);

    if (pathPlanner.route.size() > 0)
    {
        if (owner->docking_state == DS_Docked)
            owner->requestUndock();

        sf::Vector2f diff = pathPlanner.route[0] - owner->getPosition();
        float distance = sf::length(diff);

        //Normal flying towards target code
        owner->target_rotation = sf::vector2ToAngle(diff);
        float rotation_diff = fabs(sf::angleDifference(owner->target_rotation, owner->getRotation()));

        if (owner->has_warp_drive && rotation_diff < 30.0 && distance > 2000)
        {
            owner->warp_request = 1.0;
        }else{
            owner->warp_request = 0.0;
        }
        if (distance > 10000 && owner->has_jump_drive && owner->jump_delay <= 0.0)
        {
            if (rotation_diff < 1.0)
            {
                float jump = distance;
                if (pathPlanner.route.size() < 2)
                {
                    jump -= 3000;
                    if (has_missiles)
                        jump -= 5000;
                }
                if (jump > 10000)
                    jump = 10000;
                jump += random(-1500, 1500);
                owner->initializeJump(jump / 1000);
            }
        }
        if (pathPlanner.route.size() > 1)
            keep_distance = 0.0;

        if (distance > keep_distance + owner->impulse_max_speed)
            owner->impulse_request = 1.0f;
        else
            owner->impulse_request = (distance - keep_distance) / owner->impulse_max_speed;
        if (rotation_diff > 90)
            owner->impulse_request = -owner->impulse_request;
        else if (rotation_diff < 45)
            owner->impulse_request *= 1.0 - ((rotation_diff - 45.0f) / 45.0);
    }
}

void ShipAI::flyFormation(P<SpaceObject> target, sf::Vector2f offset)
{
    sf::Vector2f target_position = target->getPosition() + sf::rotateVector(owner->getOrderTargetLocation(), target->getRotation());
    pathPlanner.plan(owner->getPosition(), target_position);

    if (pathPlanner.route.size() == 1)
    {
        sf::Vector2f diff = target_position - owner->getPosition();
        float distance = sf::length(diff);

        //Formation flying code
        float r = owner->getRadius() * 5.0;
        owner->target_rotation = sf::vector2ToAngle(diff);
        if (distance > r)
        {
            float angle_diff = sf::angleDifference(owner->target_rotation, owner->getRotation());
            if (angle_diff > 10.0)
                owner->impulse_request = 0.0;
            else if (angle_diff > 5.0)
                owner->impulse_request = (10.0 - angle_diff) / 5.0;
            else
                owner->impulse_request = 1.0;
        }else{
            if (distance > r / 2.0)
            {
                owner->target_rotation += sf::angleDifference(owner->target_rotation, target->getRotation()) * (1.0 - distance / r);
                owner->impulse_request = distance / r;
            }else{
                owner->target_rotation = target->getRotation();
                owner->impulse_request = 0.0;
            }
        }
    }else{
        flyTowards(target_position);
    }
}

P<SpaceObject> ShipAI::findBestTarget(sf::Vector2f position, float radius)
{
    float target_score = 0.0;
    PVector<Collisionable> objectList = CollisionManager::queryArea(position - sf::Vector2f(radius, radius), position + sf::Vector2f(radius, radius));
    P<SpaceObject> target;
    sf::Vector2f owner_position = owner->getPosition();
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceObject> space_object = obj;
        if (!space_object || !space_object->canBeTargeted() || !owner->isEnemy(space_object) || space_object == target)
            continue;
        if (space_object->canHideInNebula() && (space_object->getPosition() - owner_position) > 5000.0f && Nebula::blockedByNebula(owner_position, space_object->getPosition()))
            continue;
        float score = targetScore(space_object);
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
    sf::Vector2f position_difference = target->getPosition() - owner->getPosition();
    float distance = sf::length(position_difference);
    //sf::Vector2f position_difference_normal = position_difference / distance;
    //float rel_velocity = dot(target->getVelocity(), position_difference_normal) - dot(getVelocity(), position_difference_normal);
    float angle_difference = sf::angleDifference(owner->getRotation(), sf::vector2ToAngle(position_difference));
    float score = -distance - fabsf(angle_difference / owner->turn_speed * owner->impulse_max_speed) * 1.5f;
    if (P<SpaceStation>(target))
        score -= 5000;
    if (distance < 5000 && has_missiles)
        score += 500;

    if (distance < beam_weapon_range)
    {
        for(int n=0; n<max_beam_weapons; n++)
        {
            if (distance < owner->beam_weapons[n].range)
            {
                if (fabs(sf::angleDifference(angle_difference, owner->beam_weapons[n].direction)) < owner->beam_weapons[n].arc / 2.0f)
                    score += 1000;
            }
        }
    }
    return score;
}

bool ShipAI::betterTarget(P<SpaceObject> new_target, P<SpaceObject> current_target)
{
    float new_score = targetScore(new_target);
    float current_score = targetScore(current_target);
    if (new_score > current_score * 1.5f)
        return true;
    if (new_score > current_score + 5000.0f)
        return true;
    return false;
}

float ShipAI::calculateFiringSolution(P<SpaceObject> target)
{
    sf::Vector2f target_position = target->getPosition();
    sf::Vector2f target_velocity = target->getVelocity();
    float target_velocity_length = sf::length(target_velocity);
    float missile_angle = sf::vector2ToAngle(target_position - owner->getPosition());
    float missile_speed = 200.0f;
    float missile_turn_rate = 10.0f;
    float turn_radius = ((360.0f / missile_turn_rate) * missile_speed) / (2.0f * M_PI);

    for(int iterations=0; iterations<10; iterations++)
    {
        float angle_diff = sf::angleDifference(missile_angle, owner->getRotation());

        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;

        sf::Vector2f turn_center = owner->getPosition() + sf::vector2FromAngle(owner->getRotation() + left_or_right) * turn_radius;
        sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_angle - left_or_right) * turn_radius;
        if (target_velocity_length < 1.0f)
        {
            //If the target is almost standing still, just target the position directly instead of using the velocity of the target in the calculations.
            float time_missile = sf::length(turn_exit - target_position) / missile_speed;
            sf::Vector2f interception = turn_exit + sf::vector2FromAngle(missile_angle) * missile_speed * time_missile;
            if ((interception - target_position) < target->getRadius() / 2)
                return missile_angle;
            missile_angle = sf::vector2ToAngle(target_position - turn_exit);
        }
        else
        {
            sf::Vector2f missile_velocity = sf::vector2FromAngle(missile_angle) * missile_speed;
            //Calculate the position where missile and the target will cross each others path.
            sf::Vector2f intersection = sf::lineLineIntersection(target_position, target_position + target_velocity, turn_exit, turn_exit + missile_velocity);
            //Calculate the time it will take for the target and missile to reach the intersection
            float turn_time = fabs(angle_diff) / missile_turn_rate;
            float time_target = sf::length((target_position - intersection)) / target_velocity_length;
            float time_missile = sf::length(turn_exit - intersection) / missile_speed + turn_time;
            //Calculate the time in which the radius will be on the intersection, to know in which time range we need to hit.
            float time_radius = (target->getRadius() / 2.0) / target_velocity_length;//TODO: This value could be improved, as it is allowed to be bigger when the angle between the missile and the ship is low
            // When both the missile and the target are at the same position at the same time, we can take a shot!
            if (fabsf(time_target - time_missile) < time_radius)
                return missile_angle;

            //When we cannot hit the target with this setup yet. Calculate a new intersection target, and aim for that.
            float guessed_impact_time = (time_target * target_velocity_length / (target_velocity_length + missile_speed)) + (time_missile * missile_speed / (target_velocity_length + missile_speed));
            sf::Vector2f new_target_position = target_position + target_velocity * guessed_impact_time;
            missile_angle = sf::vector2ToAngle(new_target_position - turn_exit);
        }
    }
    return std::numeric_limits<float>::infinity();
}
