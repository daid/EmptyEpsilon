#include <systems/destroy.h>
#include <components/destroy.h>
#include "menus/luaConsole.h"

void OnDestroySystem::destroyCallback(sp::ecs::Entity e)
{
	auto destroyed = e.getComponent<Destroyed>();
	if (destroyed)
		return;

	auto od = e.getComponent<OnDestroyed>();
	if (od && od->callback) {
		e.addComponent<Destroyed>(); // prevent recursive calls
		LuaConsole::checkResult(od->callback.call<void>(e));
	}
}
