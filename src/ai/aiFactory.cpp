#include "aiFactory.h"

ShipAIFactory* ShipAIFactory::shipAIFactoryList = NULL;

ShipAIFactory::ShipAIFactory(string name, shipAIFactoryFunc_t func)
: name(name), func(func)
{
    next = shipAIFactoryList;
    shipAIFactoryList = this;
}

shipAIFactoryFunc_t ShipAIFactory::getAIFactory(string name)
{
    for(ShipAIFactory* f = shipAIFactoryList; f; f = f->next)
        if (f->name == name)
            return f->func;
    LOG(ERROR) << "AI not found: " << name;
    return shipAIFactoryList->func;
}
