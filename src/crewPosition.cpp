#include "crewPosition.h"

string crewPositionToString(CrewPosition value) {
    switch(value) {
    case CrewPosition::helmsOfficer: return "helms";
    case CrewPosition::weaponsOfficer: return "weapons";
    case CrewPosition::engineering: return "engineering";
    case CrewPosition::scienceOfficer: return "science";
    case CrewPosition::relayOfficer: return "relay";
    case CrewPosition::tacticalOfficer: return "tactical";
    case CrewPosition::engineeringAdvanced: return "engineering+";
    case CrewPosition::operationsOfficer: return "operations";
    case CrewPosition::singlePilot: return "singlepilot";
    case CrewPosition::damageControl: return "damagecontrol";
    case CrewPosition::powerManagement: return "powermanagement";
    case CrewPosition::databaseView: return "database";
    case CrewPosition::altRelay: return "altrelay";
    case CrewPosition::commsOnly: return "commsonly";
    case CrewPosition::shipLog: return "shiplog";
    default: return "none";
    }
}

std::optional<CrewPosition> tryParseCrewPosition(string value) {
    //6/5 player crew
    if (value == "helms" || value == "helmsofficer")
        return CrewPosition::helmsOfficer;
    else if (value == "weapons" || value == "weaponsofficer")
        return CrewPosition::weaponsOfficer;
    else if (value == "engineering" || value == "engineeringsofficer")
        return CrewPosition::engineering;
    else if (value == "science" || value == "scienceofficer")
        return CrewPosition::scienceOfficer;
    else if (value == "relay" || value == "relayofficer")
        return CrewPosition::relayOfficer;

    //4/3 player crew
    else if (value == "tactical" || value == "tacticalofficer")
        return CrewPosition::tacticalOfficer;    //helms+weapons-shields
    else if (value == "engineering+" || value == "engineering+officer" || value == "engineeringadvanced" || value == "engineeringadvancedofficer")
        return CrewPosition::engineeringAdvanced;//engineering+shields
    else if (value == "operations" || value == "operationsofficer")
        return CrewPosition::operationsOfficer; //science+comms

    //1 player crew
    else if (value == "single" || value == "singlepilot")
        return CrewPosition::singlePilot;

    //extras
    else if (value == "damagecontrol")
        return CrewPosition::damageControl;
    else if (value == "powermanagement")
        return CrewPosition::powerManagement;
    else if (value == "database" || value == "databaseview")
        return CrewPosition::databaseView;
    else if (value == "altrelay")
        return CrewPosition::altRelay;
    else if (value == "commsonly")
        return CrewPosition::commsOnly;
    else if (value == "shiplog")
        return CrewPosition::shipLog;
    else
        return {};
}
