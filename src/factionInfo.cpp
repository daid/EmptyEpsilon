#include "factionInfo.h"
#include "components/faction.h"
#include "scriptInterface.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

REGISTER_SCRIPT_CLASS_NAMED(FactionInfoLegacy, "FactionInfo")
{
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setLocaleName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setGMColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setEnemy);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setFriendly);
}

static int getFactionInfo(lua_State* L)
{
    auto name = luaL_checkstring(L, 1);
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        if (info.name == name)
            return convert<P<FactionInfoLegacy>>::returnType(L, *entity.getComponent<FactionInfoLegacy*>());
    return 0;
}
/// P<FactionInfo> getFactionInfo(string faction_name)
/// Get a reference to a FactionInfo object, which can be used to modify faction to faction states.
REGISTER_SCRIPT_FUNCTION(getFactionInfo);


REGISTER_MULTIPLAYER_CLASS(FactionInfoLegacy, "FactionInfo");
FactionInfoLegacy::FactionInfoLegacy()
: MultiplayerObject("FactionInfo")
{
    entity = sp::ecs::Entity::create();
    entity.addComponent<FactionInfo>();
    entity.addComponent<FactionInfoLegacy*>(this);
}

FactionInfoLegacy::~FactionInfoLegacy()
{
    entity.destroy();
}

void FactionInfoLegacy::update(float delta)
{
}

void FactionInfoLegacy::setName(string name) { entity.getOrAddComponent<FactionInfo>().name = name; }
void FactionInfoLegacy::setLocaleName(string name) { entity.getOrAddComponent<FactionInfo>().locale_name = name; }
string FactionInfoLegacy::getName() { return entity.getOrAddComponent<FactionInfo>().name; }
string FactionInfoLegacy::getLocaleName() { return entity.getOrAddComponent<FactionInfo>().locale_name; }
string FactionInfoLegacy::getDescription() { return entity.getOrAddComponent<FactionInfo>().description; }
void FactionInfoLegacy::setGMColor(int r, int g, int b) { entity.getOrAddComponent<FactionInfo>().gm_color = glm::u8vec4(r, g, b, 255); }
glm::u8vec4 FactionInfoLegacy::getGMColor() { return entity.getOrAddComponent<FactionInfo>().gm_color; }
void FactionInfoLegacy::setDescription(string description) { entity.getOrAddComponent<FactionInfo>().description = description; }

void FactionInfoLegacy::setEnemy(P<FactionInfoLegacy> other)
{
    auto mine = entity.getOrAddComponent<FactionInfo>();
    if (!other)
    {
        LOG(WARNING) << "Tried to set a an undefined faction to enemy with " << mine.name;
        return;
    }
    auto their = other->entity.getOrAddComponent<FactionInfo>();

    //TODO
}

void FactionInfoLegacy::setFriendly(P<FactionInfoLegacy> other)
{
    auto mine = entity.getOrAddComponent<FactionInfo>();
    if (!other)
    {
        LOG(WARNING) << "Tried to set a an undefined faction to friendly with " << mine.name;
        return;
    }
    auto their = other->entity.getOrAddComponent<FactionInfo>();

    //TODO
}

void FactionInfoLegacy::reset()
{
}
