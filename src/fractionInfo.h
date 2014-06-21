#ifndef FRACTION_INFO_H
#define FRACTION_INFO_H

#include "engine.h"

const static int maxFractions = 3;
class FractionInfo;
extern FractionInfo fractionInfo[maxFractions];

enum EFractionVsFractionState
{
    FVF_Neutral,
    FVF_Friendly,
    FVF_Enemy
};

class FractionInfo
{
public:
    FractionInfo();
    
    string name;
    
    EFractionVsFractionState states[maxFractions];
    
    
    static void setState(int id1, int id2, EFractionVsFractionState state);
};

#endif//FRACTION_INFO_H
