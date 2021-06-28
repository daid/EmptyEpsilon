#ifndef CPU_SHIP_H
#define CPU_SHIP_H

#include "pathPlanner.h"
#include "spaceship.h"

enum EAIOrder
{
    AI_Idle,            //Don't do anything, don't even attack.
    AI_Roaming,         //Fly around and engage at will, without a clear target
    AI_Retreat,         //Dock on [order_target] that can restore our weapons. Find one if neccessary. Continue roaming after our missiles are restocked, or no target is found.
    AI_StandGround,     //Keep current position, do not fly away, but attack nearby targets.
    AI_DefendLocation,  //Defend against enemies getting close to [order_target_location]
    AI_DefendTarget,    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
    AI_FlyFormation,    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
    AI_FlyTowards,      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
    AI_FlyTowardsBlind, //Fly towards [order_target_location], not attacking anything
    AI_Dock,            //Dock with target
    AI_Attack,          //Attack [order_target] very specificly.
};


class ShipAI;
class CpuShip : public SpaceShip
{
    static constexpr float auto_system_repair_per_second = 0.005f;
    static constexpr float missile_resupply_time = 10.0f;

    EAIOrder orders;                    //Server only
    glm::vec2 order_target_location{};  //Server only
    P<SpaceObject> order_target;        //Server only
    ShipAI* ai;

    string new_ai_name;
public:
    CpuShip();
    virtual ~CpuShip();

    virtual void update(float delta) override;
    virtual void applyTemplateValues() override;
    void setAI(string new_ai);

    void orderIdle();
    void orderRoaming();
    void orderRoamingAt(glm::vec2 position);
    void orderRetreat(P<SpaceObject> object);
    void orderStandGround();
    void orderDefendLocation(glm::vec2 position);
    void orderDefendTarget(P<SpaceObject> object);
    void orderFlyFormation(P<SpaceObject> object, glm::vec2 offset);
    void orderFlyTowards(glm::vec2 target);
    void orderFlyTowardsBlind(glm::vec2 target);
    void orderAttack(P<SpaceObject> object);
    void orderDock(P<SpaceObject> object);

    EAIOrder getOrder() { return orders; }
    glm::vec2 getOrderTargetLocation() { return order_target_location; }
    P<SpaceObject> getOrderTarget() { return order_target; }

    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual std::unordered_map<string, string> getGMInfo() override;

    virtual string getExportLine() override;

    float missile_resupply;
};
string getAIOrderString(EAIOrder order);

template<> int convert<EAIOrder>::returnType(lua_State* L, EAIOrder o);

#endif//CPU_SHIP_H
