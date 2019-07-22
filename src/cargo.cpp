#include "cargo.h"

Cargo::Cargo(string multiplayerClassIdentifier) : MultiplayerObject(multiplayerClassIdentifier), energy_level(0), heat(0)
{
    registerMemberReplication(&heat);
    registerMemberReplication(&energy_level);
}

Cargo::Entries Cargo::getEntries()
{
    Cargo::Entries result;
    result.push_back(std::make_tuple("gui/icons/energy", "energy", int(energy_level)));
    result.push_back(std::make_tuple("gui/icons/heat", "heat", string(heat, 2)));        
    result.push_back(std::make_tuple("gui/icons/hull", "health", string(int(100 * getHealth() / getMaxHealth())) + "%"));

    return result;
}
