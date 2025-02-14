#include "scriptRandom.h"
#include "random.h"
#include <random>

static int lua_rngSeed(lua_State* L)
{
    std::mt19937_64* rng = reinterpret_cast<std::mt19937_64*>(luaL_checkudata(L, 1, "RandomGenerator"));
    rng->seed(luaL_checkinteger(L, 2));
    return 0;
}

static int lua_rngRandom(lua_State* L)
{
    std::mt19937_64* rng = reinterpret_cast<std::mt19937_64*>(luaL_checkudata(L, 1, "RandomGenerator"));
    auto fmin = luaL_checknumber(L, 2);
    auto fmax = luaL_checknumber(L, 3);
    lua_pushnumber(L, std::uniform_real_distribution<float>(fmin, fmax)(*rng));
    return 1;
}

static int lua_rngIRandom(lua_State* L)
{
    std::mt19937_64* rng = reinterpret_cast<std::mt19937_64*>(luaL_checkudata(L, 1, "RandomGenerator"));
    auto imin = luaL_checkinteger(L, 2);
    auto imax = luaL_checkinteger(L, 3);
    lua_pushinteger(L, std::uniform_int_distribution<>(imin, imax)(*rng));
    return 1;
}

static int lua_createRandomGenerator(lua_State* L)
{
    uint64_t seed = time(NULL);
    if (lua_gettop(L) > 0) {
        seed = luaL_checkinteger(L, 1);
    }
    std::mt19937_64* rng = new (lua_newuserdata(L, sizeof(std::mt19937_64))) std::mt19937_64();
    rng->seed(seed);

     if (luaL_newmetatable(L, "RandomGenerator")) {
        lua_pushvalue(L, -1);
        lua_setfield(L, -2, "__index");
        lua_pushstring(L, "sandbox");
        lua_setfield(L, -2, "__metatable");
        lua_pushcfunction(L, lua_rngSeed);
        lua_setfield(L, -2, "seed");
        lua_pushcfunction(L, lua_rngRandom);
        lua_setfield(L, -2, "random");
        lua_pushcfunction(L, lua_rngIRandom);
        lua_setfield(L, -2, "irandom");
    }
    lua_setmetatable(L, -2);
    return 1;
}


void registerScriptRandomFunctions(sp::script::Environment& env)
{
    env.setGlobal("random", static_cast<float(*)(float, float)>(&random));
    env.setGlobal("irandom", &irandom);

    env.setGlobal("RandomGenerator", &lua_createRandomGenerator);
}