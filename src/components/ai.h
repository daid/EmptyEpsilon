#pragma once

#include <memory>
#include <glm/vec2.hpp>
#include <ecs/entity.h>


enum class AIOrder
{
    Idle,            //Don't do anything, don't even attack.
    Roaming,         //Fly around and engage at will, without a clear target
    Retreat,         //Dock on [order_target] that can restore our weapons. Find one if neccessary. Continue roaming after our missiles are restocked, or no target is found.
    StandGround,     //Keep current position, do not fly away, but attack nearby targets.
    DefendLocation,  //Defend against enemies getting close to [order_target_location]
    DefendTarget,    //Defend against enemies getting close to [order_target] (falls back to Roaming if the target is destroyed)
    FlyFormation,    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
    FlyTowards,      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
    FlyTowardsBlind, //Fly towards [order_target_location], not attacking anything
    Dock,            //Dock with target
    Attack,          //Attack [order_target] very specificly.
};

class ShipAI;
class AIController
{
public:
    AIOrder orders = AIOrder::Idle;
    glm::vec2 order_target_location{};
    sp::ecs::Entity order_target;

    std::unique_ptr<ShipAI> ai;
    string new_name = "default";
};
