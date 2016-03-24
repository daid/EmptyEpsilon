#ifndef CPU_SHIP_H
#define CPU_SHIP_H

#include "pathPlanner.h"
#include "spaceship.h"

enum EAIOrder
{
    AI_Idle,            //Don't do anything, don't even attack.
    AI_Roaming,         //Fly around and engage at will, without a clear target
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

    EAIOrder orders;                    //Server only
    sf::Vector2f order_target_location; //Server only
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
    void orderRoamingAt(sf::Vector2f position);
    void orderStandGround();
    void orderDefendLocation(sf::Vector2f position);
    void orderDefendTarget(P<SpaceObject> object);
    void orderFlyFormation(P<SpaceObject> object, sf::Vector2f offset);
    void orderFlyTowards(sf::Vector2f target);
    void orderFlyTowardsBlind(sf::Vector2f target);
    void orderAttack(P<SpaceObject> object);
    void orderDock(P<SpaceObject> object);

    EAIOrder getOrder() { return orders; }
    sf::Vector2f getOrderTargetLocation() { return order_target_location; }
    P<SpaceObject> getOrderTarget() { return order_target; }
    
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;
    virtual std::unordered_map<string, string> getGMInfo() override;
    
    virtual string getExportLine() override;

    friend class GameMasterUI;
};
string getAIOrderString(EAIOrder order);

#endif//CPU_SHIP_H
