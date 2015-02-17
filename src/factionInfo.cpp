#include "factionInfo.h"

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

int FactionInfo::findFactionId(string name)
{
    for(unsigned int n = 0; n < factionInfo.size(); n++)
        if (factionInfo[n]->name == name)
            return n;
    printf("Failed to find faction: %s\n", name.c_str());
    return 0;
}

void FactionInfo::reset()
{
}
