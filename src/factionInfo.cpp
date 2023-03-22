#include "factionInfo.h"
#include "scriptInterface.h"
#include "multiplayer_server.h"

/// A FactionInfo object contains presentation details and faction relationships for member SpaceObjects.
/// EmptyEpsilon has a hardcoded limit of 32 factions (MAX_FACTIONS in factionInfo.h).
///
/// SpaceObjects belong to a faction that determines which objects are friendly, neutral, or hostile toward them.
/// For example, these relationships determine whether a SpaceObject can be targeted by weapons, docked with, or receive comms from another SpaceObject.
/// If a faction doesn't have a relationship with another faction, it treats those factions as neutral by default.
/// Therefore, new factions are neutral toward all other factions by default.
/// Faction relationships set via setEnemy(), setFriendly(), and setNeutral() are automatically reciprocated.
///
/// If this faction consideres another faction to be hostile, it can target and fire weapons at it, and CpuShips with certain orders might pursue it.
/// If neutral, this faction can't target and fire weapons at the other faction, and other factions can dock with its stations or dockable ships.
/// If friendly, this faction acts as neutral but also shares short-range radar with PlayerSpaceships in Relay, and can grant reputation points to PlayerSpaceships of the same faction.
///
/// Many scenario and comms scripts also give friendly factions benefits at a reputation cost that netural factions do not.
/// Factions are loaded from resources/factionInfo.lua upon launching a scenario, and accessed by using the getFactions() or getFactionInfoByName() global functions.
///
/// Example:
/// faction = FactionInfo():setName("USN"):setLocaleName(_("USN")) -- sets the internal and translatable faction names
/// faction:setGMColor(255,128,255) -- uses purple icons for this faction's SpaceObjects in GM and Spectator views
/// faction:setFriendly(human):setEnemy(Exuari) -- sets this faction's friendly and hostile relationships
/// faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
REGISTER_SCRIPT_CLASS(FactionInfo)
{
    /// Returns this faction's internal string name.
    /// Example: faction:getName()
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, getName);
    /// Sets this faction's internal string name, used to reference this faction regardless of EmptyEpsilon's language setting.
    /// Example: faction:setName("USN")
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setName);
    /// Returns this faction's name as presented in the currently configured user interface language.
    /// Example: faction:getLocaleName()
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, getLocaleName);
    /// Sets this faction's name as presented in the user interface.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setLocaleName(_("USN"))
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setLocaleName);
    /// Sets the RGB color used for SpaceObjects of this faction as seen on the GM and Spectator views.
    /// Defaults to white (255,255,255).
    /// Example: faction:setGMColor(255,0,0) -- sets the color to red
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setGMColor);
    /// Returns this faction's longform description as shown in its Factions ScienceDatabase child entry.
    /// Example: faction:getDescription()
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, getDescription);
    /// Sets this faction's longform description as shown in its Factions ScienceDatabase child entry.
    /// Wrap the string in the _() function to make it available for translation.
    /// Example: faction:setDescription(_("The United Stellar Navy, or USN...")) -- sets a translatable description for this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setDescription);
    /// Returns this faction's relationship with the given faction.
    /// Example: faction:getRelationship() -- returns "enemy" if hostile
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, getRelationshipWith);
    /// Sets this faction's relationship with the given faction to the given state.
    /// Example:
    /// other_faction = getFactionInfoByName("Exuari")
    /// faction:setRelationship(other_faction,"enemy") -- sets a hostile relationship with Exuari
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setRelationshipWith);
    /// Sets the given faction to be hostile to SpaceObjects of this faction.
    /// For example, Spaceships of this faction can target and fire at SpaceShips of the given faction, and vice versa.
    /// Warning: A faction can be designated as hostile to itself, but the behavior is not well-defined.
    /// Example: faction:setEnemy("Exuari") -- sets the Exuari to be hostile toward this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setEnemy);
    /// Sets the given faction to be friendly to SpaceObjects of this faction.
    /// For example, PlayerSpaceships of this faction can gain reputation with it.
    /// Example: faction:setFriendly("Human Navy") -- sets the Human Navy to be friendly toward this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setFriendly);
    /// Sets the given faction to be neutral toward SpaceObjects of this faction.
    /// This resets any existing faction relationship between this faction and the given faction.
    /// Example: faction:setNeutral("Human Navy") -- sets the Human Navy to be neutral toward this faction
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setNeutral);
    /// Resets all relationships that this faction has with other factions to neutrality.
    /// Example: faction:resetAllRelationships() -- removes all existing faction relationships
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, resetAllRelationships);
}

std::array<P<FactionInfo>, MAX_FACTIONS> factionInfo;

static int getFactionInfos(lua_State* L)
{
    PVector<FactionInfo> factions;
    factions.reserve(MAX_FACTIONS);

    for (size_t idx = 0; idx < MAX_FACTIONS; ++idx)
        if (factionInfo[idx]) { factions.emplace_back(std::move(factionInfo[idx])); }

    return convert<PVector<FactionInfo>>::returnType(L, factions);
}
/// PVector<FactionInfo> getFactionInfos()
/// Returns a 1-indexed table of all FactionInfo objects.
/// Example: getFactionInfos()[2] -- returns the second-indexed faction
REGISTER_SCRIPT_FUNCTION(getFactionInfos);

static int getFactionInfoByName(lua_State* L)
{
    const auto* name = luaL_checkstring(L, 1);

    for (size_t idx = 0; idx < MAX_FACTIONS; idx++)
    {
        if (factionInfo[idx] && factionInfo[idx]->getName() == name)
            return convert<P<FactionInfo>>::returnType(L, factionInfo[idx]);
    }

    return 0;
}
/// P<FactionInfo> getFactionInfoByName(string faction_name)
/// Returns a reference to the first FactionInfo object found with the given name.
/// Use this to modify faction details and relationships with FactionInfo functions.
/// Example: faction = getFactionInfoByName("Human Navy") -- faction = the Human Navy FactionInfo object
REGISTER_SCRIPT_FUNCTION(getFactionInfoByName);

REGISTER_MULTIPLAYER_CLASS(FactionInfo, "FactionInfo");
FactionInfo::FactionInfo()
: MultiplayerObject("FactionInfo"), index(255), gm_color({255, 255, 255, 255}), enemy_mask(0), friend_mask(0)
{
    registerMemberReplication(&index);
    registerMemberReplication(&gm_color);
    registerMemberReplication(&name);
    registerMemberReplication(&locale_name);
    registerMemberReplication(&description);
    registerMemberReplication(&enemy_mask);
    registerMemberReplication(&friend_mask);

    if (game_server)
    {
        for (size_t idx = 0; idx < MAX_FACTIONS; idx++)
        {
            if (!factionInfo[idx])
            {
                factionInfo[idx] = this;
                index = idx;
                setFriendly(this);
                return;
            }
        }

        LOG(ERROR) << "Failed to add a faction beyond the limit of " << MAX_FACTIONS << " factions.";
        destroy();
    }
}

FactionInfo::~FactionInfo()
{
}

void FactionInfo::update(float delta)
{
    if (index < MAX_FACTIONS) { factionInfo[index] = this; }
    else { LOG(ERROR) << "Faction " << name << "has index " << index << " outside of limit " << MAX_FACTIONS << "."; }
}

void FactionInfo::setName(string name)
{
    this->name = name;

    // Also set the locale name if it's unset.
    if (locale_name == "") { setLocaleName(name); }
}

void FactionInfo::setNeutral(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Failed to set an undefined faction to be neutral with " << name;
        return;
    }

    friend_mask &=~(1U << other->index);
    other->friend_mask &=~(1U << index);
    enemy_mask &=~(1 << other->index);
    other->enemy_mask &=~(1 << index);
}

void FactionInfo::setEnemy(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Failed to set an undefined faction to be an enemy of " << name;
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
        LOG(WARNING) << "Failed to set an undefined faction to be friendly with " << name;
        return;
    }

    friend_mask |= (1U << other->index);
    other->friend_mask |= (1U << index);
    enemy_mask &=~(1 << other->index);
    other->enemy_mask &=~(1 << index);
}

void FactionInfo::resetAllRelationships()
{
    for (size_t idx = 0; idx < MAX_FACTIONS; idx++)
    {
        if (factionInfo[idx] && factionInfo[idx] != this)
            this->setNeutral(factionInfo[idx]);
    }
}

EFactionVsFactionState FactionInfo::getRelationshipWith(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(ERROR) << "Given getRelationshipWith faction is invalid. Returning Neutral.";
        return FVF_Neutral;
    }

    if (enemy_mask & (1U << other->index)) { return FVF_Enemy; }
    if (friend_mask & (1U << other->index)) { return FVF_Friendly; }

    return FVF_Neutral;
}

void FactionInfo::setRelationshipWith(P<FactionInfo> other, EFactionVsFactionState state)
{
    if (!other)
    {
        LOG(WARNING) << "Given setRelationshipWith faction is invalid.";
        return;
    }

    if (state == FVF_Enemy) { setEnemy(other); }
    else if (state == FVF_Friendly) { setFriendly(other); }
    else if (state == FVF_Neutral) { setNeutral(other); }
    else { LOG(ERROR) << "Given faction relationship state is invalid."; }
}

EFactionVsFactionState FactionInfo::getRelationshipBetween(uint8_t idx0, uint8_t idx1)
{
    if (idx0 >= MAX_FACTIONS || idx1 >= MAX_FACTIONS)
    {
        LOG(ERROR) << "Given getRelationshipBetween index is outside the limit of " << MAX_FACTIONS << " factions. Returning Neutral.";
        return FVF_Neutral;
    }

    if (!factionInfo[idx0] || !factionInfo[idx1])
    {
        LOG(ERROR) << "No faction at the given getRelationshipBetween index. Returning Neutral.";
        return FVF_Neutral;
    }

    return factionInfo[idx0]->getRelationshipWith(factionInfo[idx1]);
}

EFactionVsFactionState FactionInfo::getRelationshipBetween(P<FactionInfo> faction0, P<FactionInfo> faction1)
{
    if (!faction0 || !faction1)
    {
        LOG(ERROR) << "Given faction is invalid. Returning Neutral.";
        return FVF_Neutral;
    }

    return faction0->getRelationshipWith(faction1);
}

unsigned int FactionInfo::findFactionId(string name)
{
    // Returning n, so using unsigned int.
    for (unsigned int idx = 0; idx < MAX_FACTIONS; idx++)
    {
        if (factionInfo[idx] && factionInfo[idx]->name == name)
            return idx;
    }

    LOG(ERROR) << "Failed to find faction named " << name;
    return 0;
}

void FactionInfo::reset()
{
    for (size_t idx = 0; idx < MAX_FACTIONS; idx++)
        if (factionInfo[idx]) { factionInfo[idx]->destroy(); }
}

// Define script conversion function for the EFactionVsFactionState enum.
template<> void convert<EFactionVsFactionState>::param(lua_State* L, int& idx, EFactionVsFactionState& state)
{
    string str = string(luaL_checkstring(L, idx++)).lower();

    if (str == "friendly") { state = FVF_Friendly; }
    else if (str == "neutral") { state = FVF_Neutral; }
    else if (str == "enemy" || str == "hostile") { state = FVF_Enemy; }
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
