#include "fractionInfo.h"

FractionInfo fractionInfo[maxFractions];

FractionInfo::FractionInfo()
{
    for(int n=0; n<maxFractions; n++)
        states[n] = FVF_Neutral;
    for(int n=0; n<maxFractions; n++)
        if (&fractionInfo[n] == this)
            states[n] = FVF_Friendly;
}

void FractionInfo::setState(int id1, int id2, EFractionVsFractionState state)
{
    fractionInfo[id1].states[id2] = state;
    fractionInfo[id2].states[id1] = state;
}
