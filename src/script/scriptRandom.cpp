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
    if (fmin > fmax)
        return luaL_error(L, "bad call random(%f, %f): lower bound is greater than upper bound", fmin, fmax);
    lua_pushnumber(L, static_cast<lua_Number>(std::uniform_real_distribution<float>(fmin, fmax)(*rng)));
    return 1;
}

static int lua_rngIRandom(lua_State* L)
{
    std::mt19937_64* rng = reinterpret_cast<std::mt19937_64*>(luaL_checkudata(L, 1, "RandomGenerator"));
    auto imin = luaL_checkinteger(L, 2);
    auto imax = luaL_checkinteger(L, 3);
    if (imin > imax)
        return luaL_error(L, "bad call irandom(%d, %d): lower bound is greater than upper bound", imin, imax);
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

int lua_random(lua_State* L) {
    auto a = luaL_checknumber(L, -2);
    auto b = luaL_checknumber(L, -1);
    if (a > b)
        return luaL_error(L, "bad call random(%f, %f): lower bound is greater than upper bound", a, b);
    lua_pushnumber(L, static_cast<lua_Number>(random(a, b)));
    return 1;
}

int lua_irandom(lua_State* L) {
    auto a = luaL_checkinteger(L, -2);
    auto b = luaL_checkinteger(L, -1);
    if (a > b)
        return luaL_error(L, "bad call irandom(%d, %d): lower bound is greater than upper bound", a, b);
    lua_pushinteger(L, irandom(a, b));
    return 1;
}

void registerScriptRandomFunctions(sp::script::Environment& env)
{
    /// number random(number min, number max)
    /// Returns a random floating-point number in the inclusive range of min, max.
    /// Outputs a "lower bound is greater than upper bound" error if the min value is greater than the max value.
    /// Example:
    /// local x = random(-20000, 20000) -- returns a random value, such as -931.0.69952392578
    env.setGlobal("random", &lua_random);
    /// integer irandom(integer min, integer max)
    /// Returns a random integer in the inclusive range of min, max.
    /// Outputs a "lower bound is greater than upper bound" error if the min value is greater than the max value.
    /// Example:
    /// local n = irandom(1, 6) -- equivalent to rolling a six-sided die
    env.setGlobal("irandom", &lua_irandom);

    // TODO: Note bounds error as in random/irandom, if implemented
    /// RandomGenerator RandomGenerator([integer seed])
    /// Creates a new independently seeded Mersenne Twister random generator to generate deterministic random values from the same seed.
    /// The generator's values are consistent in value and order if invoked or reinitialized multiple times with the same seed.
    /// If a seed is omitted, the current time is used as the seed.
    /// Use this to generate random values that remain consistent between runs, such as when replaying a scenario or reusing a function.
    /// The returned object has three methods:
    /// - :seed(seed) re-seeds the generator with the given integer
    /// - :random(min, max) returns a random floating-point value in the inclusive range of min, max
    /// - :irandom(min, max) returns a random integer value in the inclusive range of min, max
    /// Examples:
    /// local gen = RandomGenerator(42) -- initialize a random generator with seed 42
    /// gen:irandom(-10000, 10000) -- randomly selects and returns 5103 based on seed 42
    /// gen:irandom(-10000, 10000) -- randomly selects and returns 2781 based on seed 42
    /// -- Reseeding or reinitializing the generator deterministically resets the behavior for both random and irandom
    /// gen:seed(42) -- reseed the random generator with the same seed 42
    /// gen:irandom(-10000, 10000) -- returns 5103 based on seed 42, the same value as the first run last time
    /// gen:irandom(-10000, 10000) -- returns 2781 again
    /// gen = RandomGenerator(42) -- reinitialize the random generator with seed 42
    /// gen:random(-10000, 10000) -- returns 5103.11035..., the float version of the first value, because the reinitialized seed and range are the same
    /// -- Directly invoking RandomGenerator's initializer always returns the first random result, and the result is always at the same value proportional to the range's extents
    /// RandomGenerator(43):irandom(-10000, 10000) -- randomly selects and returns -9439 based on seed 43
    /// RandomGenerator(43):irandom(-1000, 1000) -- returns -944 (min + 56) based on the new range
    /// RandomGenerator(43):random(-1, 1) -- returns -0.943848... (min + 0.0561...)
    /// RandomGenerator(43):irandom(0, 2000) -- returns 56 (min + 56)
    env.setGlobal("RandomGenerator", &lua_createRandomGenerator);
}