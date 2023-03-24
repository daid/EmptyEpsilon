#include "factionInfo.h"
#include "scriptInterface.h"
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
REGISTER_SCRIPT_CLASS(FactionInfo)
{
    /// Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
    /// Example: faction:setName("USN")
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setName);
    /// Sets this faction's name as presented in the user interface.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setLocaleName(_("USN"))
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setLocaleName);
    /// Sets the RGB color used for SpaceObjects of this faction as seen on the GM and Spectator views.
    /// Defaults to white (255,255,255).
    /// Example: faction:setGMColor(255,0,0) -- sets the color to red
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setGMColor);
    /// Sets this faction's longform description as shown in its Factions ScienceDatabase child entry.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setDescription);
    /// Returns this faction's relationship with the given faction.
    /// Valid values are "friendly", "neutral", and "enemy".
    /// Example: faction:getRelationshipWith(exuari) -- returns "enemy"
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, getRelationshipWith);
    /// Sets the given faction to appear as hostile to SpaceObjects of this faction.
    /// For example, Spaceships of this faction can target and fire at SpaceShips of the given faction.
    /// Defaults to no hostile factions.
    /// Warning: A faction can be designated as hostile to itself, but the behavior is not well-defined.
    /// Example: faction:setEnemy("Exuari") -- sets the Exuari to appear as hostile to this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setEnemy);
    /// Sets the given faction to appear as friendly to SpaceObjects of this faction.
    /// For example, PlayerSpaceships of this faction can gain reputation with it.
    /// Defaults to no friendly factions.
    /// Example: faction:setFriendly("Human Navy") -- sets the Human Navy to appear as friendly to this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setFriendly);
}

std::array<P<FactionInfo>, 32> factionInfo;

static int getFactionInfo(lua_State* L)
{
    auto name = luaL_checkstring(L, 1);
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n] && factionInfo[n]->getName() == name)
            return convert<P<FactionInfo>>::returnType(L, factionInfo[n]);
    return 0;
}
/// P<FactionInfo> getFactionInfo(string faction_name)
/// Returns a reference to the FactionInfo object with the given name.
/// Use this to modify faction details and relationships with FactionInfo functions.
/// Example: faction = getFactionInfo("Human Navy") -- faction = the Human Navy FactionInfo object
REGISTER_SCRIPT_FUNCTION(getFactionInfo);

REGISTER_MULTIPLAYER_CLASS(FactionInfo, "FactionInfo");
FactionInfo::FactionInfo()
: MultiplayerObject("FactionInfo")
{
    index = 255;
    gm_color = {255,255,255,255};
    enemy_mask = 0;
    friend_mask = 0;

    registerMemberReplication(&index);
    registerMemberReplication(&gm_color);
    registerMemberReplication(&name);
    registerMemberReplication(&locale_name);
    registerMemberReplication(&description);
    registerMemberReplication(&enemy_mask);
    registerMemberReplication(&friend_mask);

    if (game_server) {
        for(size_t n=0; n<factionInfo.size(); n++)
        {
            if (!factionInfo[n]) {
                factionInfo[n] = this;
                index = n;
                setFriendly(this);
                return;
            }
        }
        LOG(ERROR) << "There is a limit of 32 factions.";
        destroy();
    }
}

FactionInfo::~FactionInfo()
{
}

void FactionInfo::update(float delta)
{
    if (index != 255)
        factionInfo[index] = this;
}

void FactionInfo::setEnemy(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Tried to set an undefined faction to be an enemy of " << name;
        return;
    }

    friend_mask &=~(1U << other->index);
    other->friend_mask &=~(1U << index);
    enemy_mask |= (1 << other->index);
    other->enemy_mask |= (1 << index);
}

void FactionInfo::setFriendly(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Tried to set an undefined faction to be friendly with " << name;
        return;
    }

    friend_mask |= (1U << other->index);
    other->friend_mask |= (1U << index);
    enemy_mask &=~(1 << other->index);
    other->enemy_mask &=~(1 << index);
}

EFactionVsFactionState FactionInfo::getRelationshipWith(P<FactionInfo> other)
{
    if (!other) return FVF_Neutral;
    if (enemy_mask & (1 << other->index)) return FVF_Enemy;
    if (friend_mask & (1 << other->index)) return FVF_Friendly;
    return FVF_Neutral;
}

EFactionVsFactionState FactionInfo::getRelationshipBetween(uint8_t idx0, uint8_t idx1)
{
    if (idx0 >= factionInfo.size()) return FVF_Neutral;
    if (idx1 >= factionInfo.size()) return FVF_Neutral;
    if (!factionInfo[idx0] || !factionInfo[idx1]) return FVF_Neutral;
    return factionInfo[idx0]->getRelationshipWith(factionInfo[idx1]);
}

unsigned int FactionInfo::findFactionId(string name)
{
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n] && factionInfo[n]->name == name)
            return n;
    LOG(ERROR) << "Failed to find faction: " << name;
    return 0;
}

void FactionInfo::reset()
{
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n])
            factionInfo[n]->destroy();
}

template<> void convert<EFactionVsFactionState>::param(lua_State* L, int& idx, EFactionVsFactionState& state)
{
    string str = string(luaL_checkstring(L, idx++)).lower();

    if (str == "friendly") { state = FVF_Friendly; }
    else if (str == "neutral") { state = FVF_Neutral; }
    else if (str == "enemy") { state = FVF_Enemy; }
    else { state = FVF_Neutral; }
}

template<> int convert<EFactionVsFactionState>::returnType(lua_State* L, EFactionVsFactionState state)
{
    switch (state)
    {
    case FVF_Friendly:
        lua_pushstring(L, "friendly");
        return 1;
    case FVF_Neutral:
        lua_pushstring(L, "neutral");
        return 1;
    case FVF_Enemy:
        lua_pushstring(L, "enemy");
        return 1;
    default:
        return 0;
    }
}
