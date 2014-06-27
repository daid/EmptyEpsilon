#include "factionInfo.h"

FactionInfo factionInfo[maxFactions];

FactionInfo::FactionInfo()
{
    for(int n=0; n<maxFactions; n++)
        states[n] = FVF_Neutral;
    for(int n=0; n<maxFactions; n++)
        if (&factionInfo[n] == this)
            states[n] = FVF_Friendly;
}

void FactionInfo::setState(int id1, int id2, EFactionVsFactionState state)
{
    factionInfo[id1].states[id2] = state;
    factionInfo[id2].states[id1] = state;
}
