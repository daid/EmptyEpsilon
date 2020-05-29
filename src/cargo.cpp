#include "cargo.h"

Cargo::Cargo(string multiplayerClassIdentifier) : MultiplayerObject(multiplayerClassIdentifier), energy_level(0), heat(0)
{
    registerMemberReplication(&callsign);
    registerMemberReplication(&heat);
    registerMemberReplication(&energy_level);
    for(int n = 0; n < MW_Count; n++)
    {
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }
}

Cargo::Entries Cargo::getEntries()
{
    Cargo::Entries result;
    result.push_back(std::make_tuple("gui/icons/energy", "energie", int(energy_level)));
    result.push_back(std::make_tuple("gui/icons/status_overheat", "surchauffe", string(heat, 2)));

    for(int n = 0; n < MW_Count; n++)
        if (weapon_storage_max[n] > 0)
        {
            string label = " ";
            string icon = " ";
            switch(EMissileWeapons(n))
            {
            case MW_None:
                label = "-";
                break;
            case MW_Homing:
                label = "TCC";
                icon = "gui/icons/weapon-homing.png";
                break;
            case MW_Nuke:
                label = "TCN";
                icon = "gui/icons/weapon-nuke.png";
                break;
            case MW_Mine:
                label = "Mine";
                icon = "gui/icons/weapon-mine.png";
                break;
            case MW_EMP:
                label = "TCI";
                icon = "gui/icons/weapon-emp.png";
                break;
            case MW_HVLI:
                label = "TBHV";
                icon = "gui/icons/weapon-hvli.png";
                break;
            default:
                label = "UNK: " + string(n);
                icon = " ";
                break;
            }
            result.push_back(std::make_tuple(icon, label, string(weapon_storage[n]) + "/" + string(weapon_storage_max[n])));
        }
    return result;
}

