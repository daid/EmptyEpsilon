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
    sf::Vector2f position_diff = target->getPosition() - owner->getPosition();
    float distance = sf::length(position_diff);

    switch(attack_state)
    {
    case dive:
        if (distance < 2500 + target->getRadius() && has_missiles)
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

        flyTowards(target->getPosition(), 500.0);

        if (distance < 500 + target->getRadius())
        {
            aggression += random(0, 0.05);
            
            attack_state = evade;
            timeout = 30.0f - std::min(aggression, 1.0f) * 20.0f;

            float target_dir = sf::vector2ToAngle(position_diff);
            float a_diff = sf::angleDifference(target_dir, owner->getRotation());
            if (a_diff < 0)
                evade_direction = target_dir - random(25, 40);
            else
                evade_direction = target_dir + random(25, 40);
        }
        if (owner->front_shield < owner->front_shield_max * (1.0f - aggression))
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
        if (owner->front_shield > owner->front_shield_max * 0.9 || timeout <= 0.0)
        {
            attack_state = dive;
        }else{
            sf::Vector2f target_position = target->getPosition();
            float circle_distance = 2000.0f + target->getRadius() * 2.0 + owner->getRadius() * 2.0;
            target_position += sf::vector2FromAngle(sf::vector2ToAngle(target_position - owner->getPosition()) + 170.0f) * circle_distance;
            flyTowards(target_position);
        }
        break;
    }
}
