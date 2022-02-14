#include "factionInfo.h"
#include "scriptInterface.h"
#include "multiplayer_server.h"


REGISTER_SCRIPT_CLASS(FactionInfo)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setLocaleName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setGMColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setEnemy);
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
/// Get a reference to a FactionInfo object, which can be used to modify faction to faction states.
REGISTER_SCRIPT_FUNCTION(getFactionInfo);


REGISTER_MULTIPLAYER_CLASS(FactionInfo, "FactionInfo");
FactionInfo::FactionInfo()
: MultiplayerObject("FactionInfo")
{
    index = 255;
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
        LOG(WARNING) << "Tried to set a an undefined faction to enemy with " << name;
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
        LOG(WARNING) << "Tried to set a an undefined faction to friendly with " << name;
        return;
    }

    friend_mask |= (1U << other->index);
    other->friend_mask |= (1U << index);
    enemy_mask &=~(1 << other->index);
    other->enemy_mask &=~(1 << index);
}

EFactionVsFactionState FactionInfo::getState(P<FactionInfo> other)
{
    if (!other) return FVF_Neutral;
    if (enemy_mask & (1 << other->index)) return FVF_Enemy;
    if (friend_mask & (1 << other->index)) return FVF_Friendly;
    return FVF_Neutral;
}

EFactionVsFactionState FactionInfo::getState(uint8_t idx0, uint8_t idx1)
{
    if (idx0 >= factionInfo.size()) return FVF_Neutral;
    if (idx1 >= factionInfo.size()) return FVF_Neutral;
    if (!factionInfo[idx0] || !factionInfo[idx1]) return FVF_Neutral;
    return factionInfo[idx0]->getState(factionInfo[idx1]);
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
