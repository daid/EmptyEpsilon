#include "spaceObjects/nebula.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/scanProbe.h"
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
    weapon_direction = EWeaponDirection::Front;

    update_target_delay = 0.0;
}

ShipAI::~ShipAI()
{
}

bool ShipAI::canSwitchAI()
{
    return true;
}

void ShipAI::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f draw_position, float scale)
{
    sf::Vector2f world_position = owner->getPosition();
    P<SpaceObject> target = owner->getTarget();
    if (target)
    {
        sf::VertexArray a(sf::Lines, 2);
        a[0].position = draw_position;
        a[1].position = draw_position + (target->getPosition() - world_position) * scale;
        a[0].color = a[1].color = sf::Color(255, 128, 128, 64);
        window.draw(a);
    }

    sf::VertexArray a(sf::LinesStrip, pathPlanner.route.size() + 1);
    a[0].position = draw_position;
    a[0].color = sf::Color(255, 255, 255, 32);
    for(unsigned int n=0; n<pathPlanner.route.size(); n++)
    {
        a[n+1].position = draw_position + (pathPlanner.route[n] - world_position) * scale;
        a[n+1].color = sf::Color(255, 255, 255, 64);
    }
    window.draw(a);
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

static int getDirectionIndex(float direction, float arc)
{
    if (fabs(sf::angleDifference(direction, 0.0f)) < arc / 2.0f)
        return 0;
    if (fabs(sf::angleDifference(direction, 90.0f)) < arc / 2.0f)
        return 1;
    if (fabs(sf::angleDifference(direction, 180.0f)) < arc / 2.0f)
        return 2;
    if (fabs(sf::angleDifference(direction, 270.0f)) < arc / 2.0f)
        return 3;
    return -1;
}

static float getMissileWeaponStrength(EMissileWeapons type)
{
    switch(type)
    {
    case MW_Nuke:
        return 250;
    case MW_EMP:
        return 150;
    case MW_HVLI:
        return 20;
    default:
        return 35;
    }
}

void ShipAI::updateWeaponState(float delta)
{
    if (missile_fire_delay > 0.0)
        missile_fire_delay -= delta;

    //Update the weapon state, figure out which direction is our main attack vector. If we have missile and/or beam weapons, and what we should preferer.
    has_missiles = false;
    has_beams = false;
    beam_weapon_range = 0;
    best_missile_type = MW_None;

    float tube_strength_per_direction[4] = {0, 0, 0, 0};
    float beam_strength_per_direction[4] = {0, 0, 0, 0};

    //If we have weapon tubes, load them with torpedoes
    for(int n=0; n<owner->weapon_tube_count; n++)
    {
        WeaponTube& tube = owner->weapon_tube[n];
        if (tube.isEmpty() && owner->weapon_storage[MW_EMP] > 0 && tube.canLoad(MW_EMP))
            tube.startLoad(MW_EMP);
        else if (tube.isEmpty() && owner->weapon_storage[MW_Nuke] > 0 && tube.canLoad(MW_Nuke))
            tube.startLoad(MW_Nuke);
        else if (tube.isEmpty() && owner->weapon_storage[MW_Homing] > 0 && tube.canLoad(MW_Homing))
            tube.startLoad(MW_Homing);
        else if (tube.isEmpty() && owner->weapon_storage[MW_HVLI] > 0 && tube.canLoad(MW_HVLI))
            tube.startLoad(MW_HVLI);

        //When the tube is loading or loaded, add the relative strenght of this tube to the direction of this tube.
        if (tube.isLoading() || tube.isLoaded())
        {
            int index = getDirectionIndex(tube.getDirection(), 90);
            if (index >= 0)
            {
                tube_strength_per_direction[index] += getMissileWeaponStrength(tube.getLoadType()) / tube.getLoadTimeConfig();
            }
        }
    }

    for(int n=0; n<max_beam_weapons; n++)
    {
        BeamWeapon& beam = owner->beam_weapons[n];
        if (beam.getRange() > 0)
        {
            int index = getDirectionIndex(beam.getDirection(), beam.getArc());
            if (index >= 0)
            {
                beam_strength_per_direction[index] += beam.getDamage() / beam.getCycleTime();
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

    if (has_beams)
    {
        //Figure out our beam weapon range.
        for(int n=0; n<max_beam_weapons; n++)
        {
            BeamWeapon& beam = owner->beam_weapons[n];
            if (beam.getRange() > 0)
            {
                int index = getDirectionIndex(beam.getDirection(), beam.getArc());
                if (index == best_beam_index)
                {
                    beam_weapon_range += beam.getRange() * (beam.getDamage() / beam.getCycleTime()) / beam_strength_per_direction[index];
                }
            }
        }
    }
    if (has_missiles)
    {
        float best_missile_strength = 0.0;
        for(int n=0; n<owner->weapon_tube_count; n++)
        {
            WeaponTube& tube = owner->weapon_tube[n];
            if (tube.isLoading() || tube.isLoaded())
            {
                int index = getDirectionIndex(tube.getDirection(), 90);
                if (index == best_tube_index)
                {
                    EMissileWeapons type = tube.getLoadType();
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
        if (fabs(strength_per_direction[1] - strength_per_direction[3]) < 1.0)
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
    sf::Vector2f position = owner->getPosition();
    EAIOrder orders = owner->getOrder();
    sf::Vector2f order_target_location = owner->getOrderTargetLocation();
    P<SpaceObject> order_target = owner->getOrderTarget();

    //Check if we need to lose our target because it entered a nebula.
    if (target && target->canHideInNebula() && Nebula::blockedByNebula(position, target->getPosition()))
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
        pathPlanner.clear();
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
            //TODO: Find a station which can re-stock our weapons.
            pathPlanner.clear();
        }
        break;
    case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
        pathPlanner.clear();
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
    if (has_missiles && best_missile_type == MW_HVLI)
        attack_distance = 2500.0;
    if (has_beams)
        attack_distance = beam_weapon_range * 0.7;

    sf::Vector2f position_diff = target->getPosition() - owner->getPosition();
    float distance = sf::length(position_diff);

    // missile attack
    if (distance < 4500 && has_missiles)
    {
        for(int n=0; n<owner->weapon_tube_count; n++)
        {
            if (owner->weapon_tube[n].isLoaded() && missile_fire_delay <= 0.0)
            {
                float target_angle = calculateFiringSolution(target, n);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    owner->weapon_tube[n].fire(target_angle);
                    missile_fire_delay = owner->weapon_tube[n].getLoadTimeConfig() / owner->weapon_tube_count / 2.0;
                }
            }
        }
    }

    if (owner->getOrder() == AI_StandGround)
    {
        owner->target_rotation = sf::vector2ToAngle(position_diff);
    }else{
        if (weapon_direction == EWeaponDirection::Side || weapon_direction == EWeaponDirection::Left || weapon_direction == EWeaponDirection::Right)
        {
            //We have side beams, find out where we want to attack from.
            sf::Vector2f target_position = target->getPosition();
            sf::Vector2f diff = target_position - owner->getPosition();
            float angle = sf::vector2ToAngle(diff);
            if ((weapon_direction == EWeaponDirection::Side && sf::angleDifference(angle, owner->getRotation()) > 0) || weapon_direction == EWeaponDirection::Left)
                angle += 160;
            else
                angle -= 160;
            target_position += sf::vector2FromAngle(angle) * (attack_distance + target->getRadius());
            flyTowards(target_position, 0);
        }else{
            flyTowards(target->getPosition(), attack_distance);
        }
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
        if (distance > 10000 && owner->has_jump_drive && owner->jump_delay <= 0.0 && owner->jump_drive_charge >= owner->jump_drive_max_distance)
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
                if (owner->jump_drive_max_distance == 50000)
                {   //If the ship has the default max jump drive distance of 50k, then limit our jumps to 15k, else we limit ourselves to whatever the ship layout is with a bit margin.
                    if (jump > 15000)
                        jump = 15000;
                }else{
                    if (jump > owner->jump_drive_max_distance - 2000)
                        jump = owner->jump_drive_max_distance - 2000;
                }
                jump += random(-1500, 1500);
                owner->initializeJump(jump);
            }
        }
        if (pathPlanner.route.size() > 1)
            keep_distance = 0.0;

        if (distance > keep_distance + owner->impulse_max_speed * 5.0)
            owner->impulse_request = 1.0f;
        else
            owner->impulse_request = (distance - keep_distance) / owner->impulse_max_speed * 5.0;
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
        if (owner->docking_state == DS_Docked)
            owner->requestUndock();

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
        if (!space_object || !space_object->canBeTargetedBy(owner) || !owner->isEnemy(space_object) || space_object == target)
            continue;
        if (space_object->canHideInNebula() && Nebula::blockedByNebula(owner_position, space_object->getPosition()))
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
    sf::Vector2f position_difference = target->getPosition() - owner->getPosition();
    float distance = sf::length(position_difference);
    //sf::Vector2f position_difference_normal = position_difference / distance;
    //float rel_velocity = dot(target->getVelocity(), position_difference_normal) - dot(getVelocity(), position_difference_normal);
    float angle_difference = sf::angleDifference(owner->getRotation(), sf::vector2ToAngle(position_difference));
    float score = -distance - fabsf(angle_difference / owner->turn_speed * owner->impulse_max_speed) * 1.5f;
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
        for(int n=0; n<max_beam_weapons; n++)
        {
            if (distance < owner->beam_weapons[n].getRange())
            {
                if (fabs(sf::angleDifference(angle_difference, owner->beam_weapons[n].getDirection())) < owner->beam_weapons[n].getArc() / 2.0f)
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

float ShipAI::calculateFiringSolution(P<SpaceObject> target, int tube_index)
{
    if (P<ScanProbe>(target))   //Never fire missiles on scan probes
        return std::numeric_limits<float>::infinity();

    EMissileWeapons type = owner->weapon_tube[tube_index].getLoadType();

    // Search if a non enemy ship might be damaged by a missile attack on a line of fire
    sf::Vector2f target_position = target->getPosition();
    const float target_distance = sf::length(owner->getPosition() - target_position);
    const float search_distance = std::min(4500.0, target_distance + 500.0);
    const float target_angle = sf::vector2ToAngle(target_position - owner->getPosition());
    const float fire_angle = owner->getRotation() + owner->weapon_tube[tube_index].getDirection();
    const float search_angle = 5.0;

    PVector<Collisionable> objectList = CollisionManager::queryArea(owner->getPosition() - sf::Vector2f(search_distance, search_distance), owner->getPosition() + sf::Vector2f(search_distance, search_distance));
    foreach(Collisionable, c, objectList)
    {
        P<SpaceObject> obj = c;
        if (obj && !obj->isEnemy(owner) && (P<SpaceShip>(obj) || P<SpaceStation>(obj)))
        {
            // Ship in research triangle
            const sf::Vector2f owner_to_obj = obj->getPosition() - owner->getPosition();
            const float heading_to_obj = sf::vector2ToAngle(owner_to_obj);
            const float angle_from_fireline = fabs(sf::angleDifference(heading_to_obj, fire_angle));
            if(angle_from_fireline < search_angle){
              return std::numeric_limits<float>::infinity();
            }
        }
    }

    if (type == MW_HVLI)    //Custom HVLI targeting for AI, as the calculate firing solution
    {
        const MissileWeaponData& data = MissileWeaponData::getDataFor(type);

        //HVLI missiles do not home or turn. So use a different targeting mechanism.
        float angle_diff = sf::angleDifference(target_angle, fire_angle);

        //Target is moving. Estimate where he will be when the missile hits.
        float fly_time = target_distance / data.speed;
        target_position += target->getVelocity() * fly_time;

        //If our "error" of hitting is less then double the radius of the target, fire.
        if (fabs(angle_diff) < 80.0 && target_distance * tanf(fabs(angle_diff) / 180.0f * M_PI) < target->getRadius() * 2.0)
            return fire_angle;

        return std::numeric_limits<float>::infinity();
    }

    if (type == MW_Nuke || type == MW_EMP)
    {
        sf::Vector2f target_position = target->getPosition();

        //Check if we can sort of safely fire an Nuke/EMP. The target needs to be clear of friendly/neutrals.
        float safety_radius = 1100;
        if (sf::length(target_position - owner->getPosition()) < safety_radius)
            return std::numeric_limits<float>::infinity();
        PVector<Collisionable> object_list = CollisionManager::queryArea(target->getPosition() - sf::Vector2f(safety_radius, safety_radius), target->getPosition() + sf::Vector2f(safety_radius, safety_radius));
        foreach(Collisionable, c, object_list)
        {
            P<SpaceObject> obj = c;
            if (obj && !obj->isEnemy(owner) && (P<SpaceShip>(obj) || P<SpaceStation>(obj)))
            {
                if (sf::length(obj->getPosition() - owner->getPosition()) < safety_radius - obj->getRadius())
                {
                    return std::numeric_limits<float>::infinity();
                }
            }
        }
    }

    //Use the general weapon tube targeting to get the final firing solution.
    return owner->weapon_tube[tube_index].calculateFiringSolution(target);
}
