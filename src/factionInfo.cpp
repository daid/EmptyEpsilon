#include "factionInfo.h"
#include "engine.h"

REGISTER_SCRIPT_CLASS(FactionInfo)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setGMColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setDescription);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setEnemy);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setFriendly);
}

PVector<FactionInfo> factionInfo;

FactionInfo::FactionInfo()
{
    if (game_server) { LOG(ERROR) << "FactionInfo objects can not be created during a scenario right now."; destroy(); return; }

    foreach(FactionInfo, i, factionInfo)
        i->defaultStates.push_back(FVF_Neutral);
    factionInfo.push_back(this);

    for(unsigned int n = 0; n < factionInfo.size(); n++)
        defaultStates.push_back(FVF_Neutral);
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n] == this)
            defaultStates[n] = FVF_Friendly;
}

void FactionInfo::setEnemy(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Tried to set a an undefined faction to enemy with " << name;
        return;
    }

    int id1 = -1;
    int id2 = -1;
    for(unsigned int n = 0; n < factionInfo.size(); n++)
    {
        if (factionInfo[n] == this)
            id1 = n;
        if (factionInfo[n] == other)
            id2 = n;
    }
    if (id1 != -1 && id2 != -1)
    {
        factionInfo[id1]->defaultStates[id2] = FVF_Enemy;
        factionInfo[id2]->defaultStates[id1] = FVF_Enemy;
    }
}

void FactionInfo::setFriendly(P<FactionInfo> other)
{
    if (!other)
    {
        LOG(WARNING) << "Tried to set a an undefined faction to friendly with " << name;
        return;
    }
        
    int id1 = -1;
    int id2 = -1;
    for(unsigned int n = 0; n < factionInfo.size(); n++)
    {
        if (factionInfo[n] == this)
            id1 = n;
        if (factionInfo[n] == other)
            id2 = n;
    }
    if (id1 != -1 && id2 != -1)
    {
        factionInfo[id1]->defaultStates[id2] = FVF_Friendly;
        factionInfo[id2]->defaultStates[id1] = FVF_Friendly;
    }
}

unsigned int FactionInfo::findFactionId(string name)
{
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n]->name == name)
            return n;
    LOG(ERROR) << "Failed to find faction: " << name;
    return 0;
}

void FactionInfo::reset()
{
    states = defaultStates;
}

string FactionInfo::getExportLine()
{
    string ret = "";
    for(unsigned int n = 0; n < factionInfo.size(); n++)
    {
        if (states[n] != defaultStates[n]){
            ret += string("setFactionVsFactionState(")+
            "\"" + name + "\", "+
            "\"" + factionInfo[n]->name + "\", "+
            "\"" + getFactionVsFactionStateName(states[n]) + "\")\n";
        }
    }
    return ret;
}

static int setFactionVsFactionState(lua_State* L)
{
    string name1 = string(luaL_checkstring(L, 1));
    string name2 = string(luaL_checkstring(L, 2));
    string stateName = string(luaL_checkstring(L, 3));

    P<FactionInfo> faction_a = factionInfo[FactionInfo::findFactionId(name1)];
    unsigned int faction_b_idx = FactionInfo::findFactionId(name2);
    EFactionVsFactionState state = getFactionVsFactionStateId(stateName);
    faction_a->states[faction_b_idx] = state;

    return 0;
}

/// setFactionVsFactionState(factionName1, factionName2, stateName)
/// Sets how faction 1 treats faction 2 
REGISTER_SCRIPT_FUNCTION(setFactionVsFactionState);

EFactionVsFactionState getFactionVsFactionStateId(string stateName)
{
    string state = stateName.lower();
    if (state == "enemy")
        return FVF_Enemy;
    else if (state == "friendly")
        return FVF_Friendly;
    else
        return FVF_Neutral;
}

string getFactionVsFactionStateName(EFactionVsFactionState state){
    switch(state) {
        case FVF_Enemy: return "Enemy";
        case FVF_Friendly: return "Friendly";
        case FVF_Neutral: return "Neutral";
        default : return "Unknown";
    }
}