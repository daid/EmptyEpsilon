#include "spaceObjects/cpuShip.h"
#include "ai/missileVolleyAI.h"
#include "ai/aiFactory.h"

REGISTER_SHIP_AI(MissileVolleyAI, "missilevolley");

MissileVolleyAI::MissileVolleyAI(CpuShip* owner)
: ShipAI(owner)
{
    flank_position = Unknown;
}

bool MissileVolleyAI::canSwitchAI()
{
    return true;
}

void MissileVolleyAI::run(float delta)
{
    ShipAI::run(delta);
}

void MissileVolleyAI::runOrders()
{
    flank_position = Unknown;
    ShipAI::runOrders();
}

void MissileVolleyAI::runAttack(P<SpaceObject> target)
{
    if (!has_missiles)
    {
        ShipAI::runAttack(target);
        return;
    }

    auto position_diff = target->getPosition() - owner->getPosition();
    float target_angle = vec2ToAngle(position_diff);
    float distance = glm::length(position_diff);

    if (flank_position == Unknown)
    {
        //No flanking position. Do we want to go left or right of the target?
        auto left_point = target->getPosition() + vec2FromAngle(target_angle - 120) * 3500.0f;
        auto right_point = target->getPosition() + vec2FromAngle(target_angle + 120) * 3500.0f;
        if (angleDifference(vec2ToAngle(left_point - owner->getPosition()), owner->getRotation()) < angleDifference(vec2ToAngle(right_point - owner->getPosition()), owner->getRotation()))
        {
            flank_position = Left;
        }else{
            flank_position = Right;
        }
    }

    if (distance < 4500 && has_missiles)
    {
        bool all_possible_loaded = true;
        for(int n=0; n<owner->weapon_tube_count; n++)
        {
            WeaponTube& weapon_tube = owner->weapon_tube[n];
            //Base AI class already loads the tubes with available missiles.
            //If a tube is not loaded, but is currently being load with a new missile, then we still have missiles to load before we want to fire.
            if (weapon_tube.isLoading())
            {
                all_possible_loaded = false;
                break;
            }
        }

        if (all_possible_loaded)
        {
            int can_fire_count = 0;
            for(int n=0; n<owner->weapon_tube_count; n++)
            {
                float target_angle = calculateFiringSolution(target, n);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    can_fire_count++;
                }
            }

            for(int n=0; n<owner->weapon_tube_count; n++)
            {
                float target_angle = calculateFiringSolution(target, n);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    can_fire_count--;
                    if (can_fire_count == 0)
                        owner->weapon_tube[n].fire(target_angle);
                    else if ((can_fire_count % 2) == 0)
                        owner->weapon_tube[n].fire(target_angle + 20.0f * (can_fire_count / 2));
                    else
                        owner->weapon_tube[n].fire(target_angle - 20.0f * ((can_fire_count + 1) / 2));
                }
            }
        }
    }

    glm::vec2 target_position{};
    if (flank_position == Left)
    {
        target_position = target->getPosition() + vec2FromAngle(target_angle - 120) * 3500.0f;
    }else{
        target_position = target->getPosition() + vec2FromAngle(target_angle + 120) * 3500.0f;
    }

    if (owner->getOrder() == AI_StandGround)
    {
        owner->target_rotation = vec2ToAngle(target_position - owner->getPosition());
    }else{
        flyTowards(target_position, 0.0f);
    }
}
