#include "factionInfo.h"

REGISTER_SCRIPT_CLASS(FactionInfo)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setName);
    REGISTER_SCRIPT_CLASS_FUNCTION(FactionInfo, setLocaleName);
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
        i->states.push_back(FVF_Neutral);
    factionInfo.push_back(this);

    for(unsigned int n = 0; n < factionInfo.size(); n++)
        states.push_back(FVF_Neutral);
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n] == this)
            states[n] = FVF_Friendly;
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
        factionInfo[id1]->states[id2] = FVF_Enemy;
        factionInfo[id2]->states[id1] = FVF_Enemy;
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
        factionInfo[id1]->states[id2] = FVF_Friendly;
        factionInfo[id2]->states[id1] = FVF_Friendly;
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
}
