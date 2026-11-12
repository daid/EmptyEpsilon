#include <systems/destroy.h>
#include <components/destroy.h>
#include "menus/luaConsole.h"

static bool tearing_down = false;

void OnDestroySystem::destroyCallback(sp::ecs::Entity e)
{
	if (tearing_down)
		return;
	auto destroyed = e.getComponent<Destroyed>();
	if (destroyed)
		return;

	auto od = e.getComponent<OnDestroyed>();
	if (od && od->callback) {
		e.addComponent<Destroyed>(); // prevent recursive calls
		LuaConsole::checkResult(od->callback.call<void>(e));
	}
}

void OnDestroySystem::destroyAllEntities()
{
	tearing_down = true;
	sp::ecs::Entity::destroyAllEntities();
	tearing_down = false;
}
