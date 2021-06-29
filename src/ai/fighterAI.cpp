#include "spaceObjects/cpuShip.h"
#include "ai/fighterAI.h"
#include "ai/aiFactory.h"


REGISTER_SHIP_AI(FighterAI, "fighter");

FighterAI::FighterAI(CpuShip* owner)
: ShipAI(owner)
{
    attack_state = dive;
    timeout = 0.0;
    aggression = random(0.0, 0.25);
}

bool FighterAI::canSwitchAI()
{
    if (owner->getTarget() && (has_missiles || has_beams))
    {
        if (attack_state == dive)
            return false;
    }
    return true;
}

void FighterAI::run(float delta)
{
    if (timeout > 0.0)
        timeout -= delta;
    ShipAI::run(delta);
}

void FighterAI::runOrders()
{
    if (aggression > 0.5)
        aggression -= random(0.0, 0.25);
    ShipAI::runOrders();
}

void FighterAI::runAttack(P<SpaceObject> target)
{
    auto position_diff = target->getPosition() - owner->getPosition();
    float distance = glm::length(position_diff);

    switch(attack_state)
    {
    case dive:
        if (distance < 2500 + target->getRadius() && has_missiles)
        {
            for(int n=0; n<owner->weapon_tube_count; n++)
            {
                if (owner->weapon_tube[n].isLoaded() && missile_fire_delay <= 0.0)
                {
                    float target_angle = calculateFiringSolution(target, owner->weapon_tube[n].getLoadType());
                    if (target_angle != std::numeric_limits<float>::infinity())
                    {
                        owner->weapon_tube[n].fire(target_angle);
                        missile_fire_delay = owner->weapon_tube[n].getLoadTimeConfig() / owner->weapon_tube_count / 2.0;
                    }
                }
            }
        }

        flyTowards(target->getPosition(), 500.0);

        if (distance < 500 + target->getRadius())
        {
            aggression += random(0, 0.05);

            attack_state = evade;
            timeout = 30.0f - std::min(aggression, 1.0f) * 20.0f;

            float target_dir = vec2ToAngle(position_diff);
            float a_diff = sf::angleDifference(target_dir, owner->getRotation());
            if (a_diff < 0)
                evade_direction = target_dir - random(25, 40);
            else
                evade_direction = target_dir + random(25, 40);
        }
        if (owner->shield_level[0] < owner->shield_max[0] * (1.0f - aggression))
        {
            attack_state = recharge;
            aggression += random(0.1, 0.25);
            timeout = 60.0f - std::min(aggression, 1.0f) * 20.0f;
        }
        break;
    case evade:
        if (distance > 2000 + target->getRadius() || timeout <= 0.0)
        {
            attack_state = dive;
        }
        else
        {
            owner->target_rotation = evade_direction;
            owner->impulse_request = 1.0;
        }
        break;
    case recharge:
        if (owner->shield_level[0] > owner->shield_max[0] * 0.9 || timeout <= 0.0)
        {
            attack_state = dive;
        }else{
            auto target_position = target->getPosition();
            float circle_distance = 2000.0f + target->getRadius() * 2.0 + owner->getRadius() * 2.0;
            target_position += vec2FromAngle(vec2ToAngle(target_position - owner->getPosition()) + 170.0f) * circle_distance;
            flyTowards(target_position);
        }
        break;
    }
}
