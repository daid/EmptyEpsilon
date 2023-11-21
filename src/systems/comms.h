#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include "stringImproved.h"


struct lua_State;
class CommsSystem : public sp::ecs::System
{
public:
    // Base time it takes to perform an action
    constexpr static float channel_open_time = 2.0;

    void update(float delta) override;

    static void openTo(sp::ecs::Entity player, sp::ecs::Entity target);
    static void answer(sp::ecs::Entity player, bool allow);
    static void close(sp::ecs::Entity player);
    static bool hailByGM(sp::ecs::Entity player, string target_name);
    static bool hailByObject(sp::ecs::Entity player, sp::ecs::Entity source, const string& message);
    static void selectScriptReply(sp::ecs::Entity player, int index);
    static void textReply(sp::ecs::Entity player, const string& message);

    static void addCommsIncommingMessage(sp::ecs::Entity player, string message);
    static void addCommsOutgoingMessage(sp::ecs::Entity player, string message);
    static void setCommsMessage(sp::ecs::Entity player, string message);

    static int luaSetCommsMessage(lua_State* L);
    static int luaAddCommsReply(lua_State* L);
    static int luaCommsSwitchToGM(lua_State* L);
private:
    static bool openChannel(sp::ecs::Entity player, sp::ecs::Entity target);
};
