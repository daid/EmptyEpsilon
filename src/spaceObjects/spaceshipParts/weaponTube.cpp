#include "weaponTube.h"
#include "spaceObjects/missiles/EMPMissile.h"
#include "spaceObjects/missiles/homingMissile.h"
#include "spaceObjects/mine.h"
#include "spaceObjects/missiles/nuke.h"
#include "spaceObjects/missiles/hvli.h"
#include "spaceObjects/spaceship.h"
#include "multiplayer_server.h"
#include <SDL_assert.h>


WeaponTube::WeaponTube()
{
    parent = nullptr;

    load_time = 8.0;
    direction = 0;
    type_allowed_mask = (1 << MW_Count) - 1;
    type_loaded = MW_None;
    state = WTS_Empty;
    delay = 0.0;
    tube_index = 0;
    size = MS_Medium;
}

void WeaponTube::setParent(SpaceShip* parent)
{
    SDL_assert(!this->parent);
    this->parent = parent;

    parent->registerMemberReplication(&load_time);
    parent->registerMemberReplication(&type_allowed_mask);
    parent->registerMemberReplication(&direction);
    parent->registerMemberReplication(&size);

    parent->registerMemberReplication(&type_loaded);
    parent->registerMemberReplication(&state);
    parent->registerMemberReplication(&delay, 0.5);
}

float WeaponTube::getLoadTimeConfig()
{
    return load_time;
}

void WeaponTube::setLoadTimeConfig(float load_time)
{
    this->load_time = load_time;
}

void WeaponTube::setIndex(int index)
{
    tube_index = index;
}

void WeaponTube::setDirection(float direction)
{
    this->direction = direction;
}

float WeaponTube::getDirection()
{
    return direction;
}

void WeaponTube::startLoad(EMissileWeapons type)
{
    if (!canLoad(type))
        return;
    if (state != WTS_Empty)
        return;
    if (parent->weapon_storage[type] <= 0)
        return;

    state = WTS_Loading;
    delay = load_time;
    parent->forceMemberReplicationUpdate(&delay);
    type_loaded = type;
    parent->weapon_storage[type]--;
}

void WeaponTube::startUnload()
{
    if (state == WTS_Loaded)
    {
        state = WTS_Unloading;
        delay = load_time;
        parent->forceMemberReplicationUpdate(&delay);
    }
}

void WeaponTube::fire(float target_angle)
{
    parent->didAnOffensiveAction();

    if (parent->docking_state != DS_NotDocking) return;
    if (parent->current_warp > 0.0f) return;
    if (state != WTS_Loaded) return;

    if (type_loaded == MW_HVLI)
    {
        fire_count = 5;
        state = WTS_Firing;
        delay = 0.0;
    }else{
        spawnProjectile(target_angle);
        state = WTS_Empty;
        type_loaded = MW_None;
    }
}

void WeaponTube::spawnProjectile(float target_angle)
{
    auto fireLocation = parent->getPosition() + rotateVec2(parent->ship_template->model_data->getTubePosition2D(tube_index), parent->getRotation());
    switch(type_loaded)
    {
    case MW_Homing:
        {
            P<HomingMissile> missile = new HomingMissile();
            missile->owner = parent;
            missile->setFactionId(parent->getFactionId());
            missile->target_id = parent->target_id;
            missile->setPosition(fireLocation);
            missile->setRotation(parent->getRotation() + direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(size);
        }
        break;
    case MW_Nuke:
        {
            P<Nuke> missile = new Nuke();
            missile->owner = parent;
            missile->setFactionId(parent->getFactionId());
            missile->target_id = parent->target_id;
            missile->setPosition(fireLocation);
            missile->setRotation(parent->getRotation() + direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(size);
        }
        break;
    case MW_Mine:
        {
            P<Mine> missile = new Mine();
            missile->owner = parent;
            missile->setFactionId(parent->getFactionId());
            missile->setPosition(fireLocation);
            missile->setRotation(parent->getRotation() + direction);
            missile->eject();
        }
        break;
    case MW_HVLI:
        {
            P<HVLI> missile = new HVLI();
            missile->owner = parent;
            missile->setFactionId(parent->getFactionId());
            missile->setPosition(fireLocation);
            missile->setRotation(parent->getRotation() + direction);
            missile->target_angle = parent->getRotation() + direction;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(size);
        }
        break;
    case MW_EMP:
        {
            P<EMPMissile> missile = new EMPMissile();
            missile->owner = parent;
            missile->setFactionId(parent->getFactionId());
            missile->target_id = parent->target_id;
            missile->setPosition(fireLocation);
            missile->setRotation(parent->getRotation() + direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(size);
        }
        break;
    default:
        break;
    }
}

bool WeaponTube::canLoad(EMissileWeapons type)
{
    if (type <= MW_None || type >= MW_Count)
        return false;
    if (type_allowed_mask & (1 << type))
        return true;
    return false;
}

bool WeaponTube::canOnlyLoad(EMissileWeapons type)
{
    if (type_allowed_mask == (1U << type))
        return true;
    return false;
}

void WeaponTube::allowLoadOf(EMissileWeapons type)
{
    type_allowed_mask |= (1 << type);
}

void WeaponTube::disallowLoadOf(EMissileWeapons type)
{
    type_allowed_mask &=~(1 << type);
}

void WeaponTube::forceUnload()
{
    if (state != WTS_Empty && type_loaded != MW_None)
    {
        state = WTS_Empty;
        if (parent->weapon_storage[type_loaded] < parent->weapon_storage_max[type_loaded])
            parent->weapon_storage[type_loaded] ++;
        type_loaded = MW_None;
    }
}

void WeaponTube::update(float delta)
{
    if (delay > 0.0f)
    {
        delay -= delta * parent->getSystemEffectiveness(SYS_MissileSystem);
    }else{
        switch(state)
        {
        case WTS_Loading:
            state = WTS_Loaded;
            break;
        case WTS_Unloading:
            state = WTS_Empty;
            if (parent->weapon_storage[type_loaded] < parent->weapon_storage_max[type_loaded])
                parent->weapon_storage[type_loaded] ++;
            type_loaded = MW_None;
            break;
        case WTS_Firing:
            if (game_server)
            {
                spawnProjectile(0);

                fire_count -= 1;
                if (fire_count > 0)
                {
                    delay = 1.5;
                }
                else
                {
                    state = WTS_Empty;
                    type_loaded = MW_None;
                }
            }
            break;
        default:
            break;
        }
    }
}

bool WeaponTube::isEmpty()
{
    return state == WTS_Empty;
}

bool WeaponTube::isLoaded()
{
    return state == WTS_Loaded;
}

bool WeaponTube::isLoading()
{
    return state == WTS_Loading;
}

bool WeaponTube::isUnloading()
{
    return state == WTS_Unloading;
}

bool WeaponTube::isFiring()
{
    return state == WTS_Firing;
}

float WeaponTube::getLoadProgress()
{
    return 1.0f - delay / load_time;
}

float WeaponTube::getUnloadProgress()
{
    return delay / load_time;
}

EMissileWeapons WeaponTube::getLoadType()
{
    return type_loaded;
}

string WeaponTube::getTubeName()
{
    if (std::abs(angleDifference(0.0f, direction)) <= 45)
        return tr("tube","Front");
    if (std::abs(angleDifference(90.0f, direction)) < 45)
        return tr("tube","Right");
    if (std::abs(angleDifference(-90.0f, direction)) < 45)
        return tr("tube","Left");
    if (std::abs(angleDifference(180.0f, direction)) <= 45)
        return tr("tube","Rear");
    return "?" + string(direction);
}

// Coordinate transform from global reference frame (X: right/east, Y: down/south)
// to weapon tube reference frame (X: right of tube, Y: direction of fire)
static glm::vec2 transform_global_to_tube(glm::vec2 vec, float angle)
{
    const float heading = angle + 0.5f*float(M_PI);
    const float c = glm::cos(heading);
    const float s = glm::sin(heading);
    return glm::vec2(c*vec.x + s*vec.y, s*vec.x - c*vec.y);
}

float WeaponTube::calculateFiringSolution(P<SpaceObject> target)
{
    const MissileWeaponData& missile = MissileWeaponData::getDataFor(type_loaded);
    float missile_angle;
    if (!target || missile.turnrate == 0.0f)
    {
        missile_angle = std::numeric_limits<float>::infinity();
    }
    else
    {
        const float tube_angle = glm::radians(parent->getRotation() + direction);
        const float turn_rate = glm::radians(missile.turnrate);
        const float turn_radius = missile.speed / turn_rate;

        // Get target parameters in the tube centered reference frame:
        const glm::vec2 target_position = transform_global_to_tube(target->getPosition() - parent->getPosition(), tube_angle);
        const glm::vec2 target_velocity = transform_global_to_tube(target->getVelocity() - parent->getVelocity(), tube_angle);

        const int MAX_ITER = 10;
        const float tolerance = 0.1f * target->getRadius();
        bool converged = false;
        glm::vec2 aim_position = target_position; // Set initial aim point
        float turn_direction; // Left: -1, Right: +1, No turn: 0
        float turn_angle; // In radians. Value of 0 means no turn.
        for (int iterations=0; iterations<MAX_ITER && converged == false; iterations++)
        {
            // Select turn direction
            // Turn in the direction of the target on condition that the target
            // is not inside the turning circle of that side. If it is inside
            // the turning circle, turn in the opposite direction.
            const float r_left = glm::length(aim_position - glm::vec2(-turn_radius, 0.0f));
            const float r_right = glm::length(aim_position - glm::vec2(turn_radius, 0.0f));
            if ((aim_position.x < 0.0f && r_left >= turn_radius) || r_right < turn_radius)
                turn_direction = -1.0f;
            else if ((aim_position.x >= 0.0f && r_right >= turn_radius) || r_left < turn_radius)
                turn_direction = 1.0f;
            else
                turn_direction = 0.0f;
            
            // Calculate turn angle
            if (turn_direction == 0.0f)
            {
                turn_angle = 0.0f;
            }
            else
            {
                const float x = turn_direction * aim_position.x;
                const float aim_radius = glm::length(aim_position - turn_direction*glm::vec2(turn_radius, 0.0f));
                const float a = glm::acos((turn_radius - x) / aim_radius);
                const float b = glm::acos(turn_radius / aim_radius);
                if (aim_position.y >= 0.0f)
                {
                    if (x >= 0.0f)
                        turn_angle = a - b;
                    else
                        turn_angle = 2.0f*float(M_PI) + a - b;
                }
                else
                {
                    turn_angle = 2.0f*float(M_PI) - a - b;
                }
            }

            // Calculate missile and target parameters at turn exit
            const float exit_time = turn_angle / turn_rate;
            const glm::vec2 missile_position_exit = turn_radius * glm::vec2(turn_direction * (1.0f - glm::cos(turn_angle)), glm::sin(turn_angle));
            const glm::vec2 missile_velocity = missile.speed * glm::vec2(turn_direction * glm::sin(turn_angle), glm::cos(turn_angle));
            const glm::vec2 target_position_exit = glm::vec2(target_position + target_velocity*exit_time);

            // Calculate nearest approach
            const glm::vec2 relative_position_exit = target_position_exit - missile_position_exit;
            const glm::vec2 relative_velocity = target_velocity - missile_velocity;
            const float relative_speed = glm::length(relative_velocity);
            float nearest_time; // Time after turn exit when nearest approach occurs
            if (relative_speed == 0.0f)
                nearest_time = 0.0f;
            else
                nearest_time = -glm::dot(relative_position_exit, relative_velocity) / relative_speed / relative_speed;
            const float nearest_distance = glm::length(relative_position_exit + relative_velocity*nearest_time);

            // Check if solution has converged or if we must adjust aim
            if (nearest_distance < tolerance && nearest_time >= 0.0f)
                converged = true;
            else
                aim_position = target_position + target_velocity*(exit_time + nearest_time);
        }
        if (converged == true && turn_angle < float(M_PI))
            missile_angle = glm::degrees(tube_angle + turn_direction*turn_angle);
        else
            missile_angle = std::numeric_limits<float>::infinity();
    }
    return missile_angle;
}

void WeaponTube::setSize(EMissileSizes size)
{
    this->size = size;
}

EMissileSizes WeaponTube::getSize()
{
    return size;
}
