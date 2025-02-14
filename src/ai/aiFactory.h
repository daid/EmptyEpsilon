#ifndef AI_FACTORY_H
#define AI_FACTORY_H

#include "engine.h"
#include "ecs/entity.h"

class ShipAI;
class ShipAIFactory;

typedef std::unique_ptr<ShipAI> (*shipAIFactoryFunc_t)(sp::ecs::Entity owner);

class ShipAIFactory
{
    static ShipAIFactory* shipAIFactoryList;
public:
    string name;
    shipAIFactoryFunc_t func;

    ShipAIFactory* next;

    ShipAIFactory(string name, shipAIFactoryFunc_t func);

    static shipAIFactoryFunc_t getAIFactory(string name);
};
#define REGISTER_SHIP_AI(c, n) \
    static std::unique_ptr<ShipAI> c ## _factory_function (sp::ecs::Entity owner) { return  std::make_unique<c>(owner); } \
    ShipAIFactory c ## _factory(n, c ## _factory_function )

#endif//AI_FACTORY_H
