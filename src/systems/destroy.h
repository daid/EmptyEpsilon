#pragma once

#include <ecs/entity.h>

class OnDestroySystem
{
public:
	static void destroyCallback(sp::ecs::Entity e);

	// Destroy every entity without running any OnDestroyed callbacks. A callback that creates an entity during
	// teardown would reuse an already freed slot (and survive into the next scenario) or grow the list forever.
	static void destroyAllEntities();
};
