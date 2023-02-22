#ifndef CPU_SHIP_H
#define CPU_SHIP_H

#include "pathPlanner.h"
#include "spaceship.h"
#include "components/ai.h"


class ShipAI;
class CpuShip : public SpaceShip
{
public:
    CpuShip();
    virtual ~CpuShip();

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

    AIOrder getOrder() { return AIOrder::Idle; }
    glm::vec2 getOrderTargetLocation() { return {}; }
    P<SpaceObject> getOrderTarget() { return nullptr; }

    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual std::unordered_map<string, string> getGMInfo() override;

    virtual string getExportLine() override;
};
string getAIOrderString(AIOrder order);
string getLocaleAIOrderString(AIOrder order);

template<> int convert<AIOrder>::returnType(lua_State* L, AIOrder o);

#endif//CPU_SHIP_H
