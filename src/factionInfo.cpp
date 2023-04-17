#include "factionInfo.h"
#include "components/faction.h"
#include "scriptInterface.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

/// A FactionInfo object contains presentation details and faction relationships for member SpaceObjects.
/// EmptyEpsilon has a hardcoded limit of 32 factions.
///
/// SpaceObjects belong to a faction that determines which objects are friendly, neutral, or hostile toward them.
/// For example, these relationships determine whether a SpaceObject can be targeted by weapons, docked with, or receive comms from another SpaceObject.
/// If a faction doesn't have a relationship with another faction, it treats those factions as neutral.
/// Friendly and hostile faction relationships are automatically reciprocated when set with setEnemy() and setFriendly().
///
/// If this faction consideres another faction to be hostile, it can target and fire weapons at it, and CpuShips with certain orders might pursue it.
/// If neutral, this faction can't target and fire weapons at the other faction, and other factions can dock with its stations or dockable ships.
/// If friendly, this faction acts as neutral but also shares short-range radar with PlayerSpaceships in Relay, and can grant reputation points to PlayerSpaceships of the same faction.
///
/// Many scenario and comms scripts also give friendly factions benefits at a reputation cost that netural factions do not.
/// Factions are loaded from resources/factionInfo.lua upon launching a scenario, and accessed by using the getFactionInfo() global function.
///
/// Example:
/// faction = FactionInfo():setName("USN"):setLocaleName(_("USN")) -- sets the internal and translatable faction names
/// faction:setGMColor(255,128,255) -- uses purple icons for this faction's SpaceObjects in GM and Spectator views
/// faction:setFriendly(human):setEnemy(Exuari) -- sets this faction's friendly and hostile relationships
/// faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
REGISTER_SCRIPT_CLASS_NAMED(FactionInfoLegacy, "FactionInfo")
{
    /// Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
    /// Example: faction:setName("USN")
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setName);
    /// Sets this faction's name as presented in the user interface.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setLocaleName(_("USN"))
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setLocaleName);
    /// Sets the RGB color used for SpaceObjects of this faction as seen on the GM and Spectator views.
    /// Defaults to white (255,255,255).
    /// Example: faction:setGMColor(255,0,0) -- sets the color to red
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setGMColor);
    /// Sets this faction's longform description as shown in its Factions ScienceDatabase child entry.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setDescription);
    /// Sets the given faction to appear as hostile to SpaceObjects of this faction.
    /// For example, Spaceships of this faction can target and fire at SpaceShips of the given faction.
    /// Defaults to no hostile factions.
    /// Warning: A faction can be designated as hostile to itself, but the behavior is not well-defined.
    /// Example: faction:setEnemy("Exuari") -- sets the Exuari to appear as hostile to this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setEnemy);
    /// Sets the given faction to appear as friendly to SpaceObjects of this faction.
    /// For example, PlayerSpaceships of this faction can gain reputation with it.
    /// Defaults to no friendly factions.
    /// Example: faction:setFriendly("Human Navy") -- sets the Human Navy to appear as friendly to this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setFriendly);
    /// Sets the given faction to appear as neutral to SpaceObjects of this faction.
    /// This removes any existing faction relationships between the two factions.
    /// Example: faction:setNeutral(human_navy) -- sets the Human Navy to appear as neutral to this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfoLegacy, setNeutral);
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
/// Returns a reference to the FactionInfo object with the given name.
/// Use this to modify faction details and relationships with FactionInfo functions.
/// Example: faction = getFactionInfo("Human Navy") -- faction = the Human Navy FactionInfo object
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
    auto& mine = entity.getOrAddComponent<FactionInfo>();
    if (!other)
    {
        LOG(WARNING) << "Tried to set an undefined faction to be an enemy of " << mine.name;
        return;
    }
    auto& their = other->entity.getOrAddComponent<FactionInfo>();
    mine.setRelation(other->entity, FactionRelation::Enemy);
    their.setRelation(entity, FactionRelation::Enemy);
}

void FactionInfoLegacy::setFriendly(P<FactionInfoLegacy> other)
{
    auto& mine = entity.getOrAddComponent<FactionInfo>();
    if (!other)
    {
        LOG(WARNING) << "Tried to set an undefined faction to be friendly with " << mine.name;
        return;
    }
    auto& their = other->entity.getOrAddComponent<FactionInfo>();
    mine.setRelation(other->entity, FactionRelation::Friendly);
    their.setRelation(entity, FactionRelation::Friendly);
}

void FactionInfoLegacy::setNeutral(P<FactionInfoLegacy> other)
{
    auto& mine = entity.getOrAddComponent<FactionInfo>();
    if (!other)
    {
        LOG(WARNING) << "Tried to set an undefined faction to be neutral with " << mine.name;
        return;
    }
    auto& their = other->entity.getOrAddComponent<FactionInfo>();
    mine.setRelation(other->entity, FactionRelation::Neutral);
    their.setRelation(entity, FactionRelation::Neutral);
}

void FactionInfoLegacy::reset()
{
}
