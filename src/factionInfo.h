#ifndef FACTION_INFO_H
#define FACTION_INFO_H

#include "engine.h"

const static int maxFactions = 5;
class FactionInfo;
extern FactionInfo factionInfo[maxFactions];

enum EFactionVsFactionState
{
    FVF_Neutral,
    FVF_Friendly,
    FVF_Enemy
};

class FactionInfo
{
public:
    FactionInfo();
    
    string name;
    sf::Color gm_color;
    
    EFactionVsFactionState states[maxFactions];
    
    
    static void setState(int id1, int id2, EFactionVsFactionState state);
};

#endif//Faction_INFO_H
