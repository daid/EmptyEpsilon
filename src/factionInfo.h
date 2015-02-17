#ifndef FACTION_INFO_H
#define FACTION_INFO_H

#include "engine.h"

class FactionInfo;
extern PVector<FactionInfo> factionInfo;

enum EFactionVsFactionState
{
    FVF_Neutral,
    FVF_Friendly,
    FVF_Enemy
};

class FactionInfo : public PObject
{
private:
    int callsign_counter;
public:
    FactionInfo();
    
    string name;
    string description;
    sf::Color gm_color;
    
    std::vector<EFactionVsFactionState> states;
    
    void setName(string name) { this->name = name; }
    void setGMColor(int r, int g, int b) { gm_color = sf::Color(r, g, b); }
    void setDescription(string description) { this->description = description; }
    void setEnemy(P<FactionInfo> other);
    void setFriendly(P<FactionInfo> other);
    
    void reset();
    
    static int findFactionId(string name);
};

#endif//Faction_INFO_H
