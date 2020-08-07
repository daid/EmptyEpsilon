#ifndef AI_FACTORY_H
#define AI_FACTORY_H

#include "engine.h"

class ShipAI;
class CpuShip;
class ShipAIFactory;

typedef ShipAI* (*shipAIFactoryFunc_t)(CpuShip* owner);

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
    static ShipAI* c ## _factory_function (CpuShip* owner) { return new c(owner); } \
    ShipAIFactory c ## _factory(n, c ## _factory_function )

#endif//AI_FACTORY_H
