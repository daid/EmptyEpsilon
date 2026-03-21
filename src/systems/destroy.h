#pragma once

#include <ecs/entity.h>

class OnDestroySystem
{
public:
	static void destroyCallback(sp::ecs::Entity e);
};
