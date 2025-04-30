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

bool tryParseCrewPosition(string value, CrewPosition& result) {
    //6/5 player crew
    if (value == "helms" || value == "helmsofficer")
        result = CrewPosition::helmsOfficer;
    else if (value == "weapons" || value == "weaponsofficer")
        result = CrewPosition::weaponsOfficer;
    else if (value == "engineering" || value == "engineeringsofficer")
        result = CrewPosition::engineering;
    else if (value == "science" || value == "scienceofficer")
        result = CrewPosition::scienceOfficer;
    else if (value == "relay" || value == "relayofficer")
        result = CrewPosition::relayOfficer;

    //4/3 player crew
    else if (value == "tactical" || value == "tacticalofficer")
        result = CrewPosition::tacticalOfficer;    //helms+weapons-shields
    else if (value == "engineering+" || value == "engineering+officer" || value == "engineeringadvanced" || value == "engineeringadvancedofficer")
        result = CrewPosition::engineeringAdvanced;//engineering+shields
    else if (value == "operations" || value == "operationsofficer")
        result = CrewPosition::operationsOfficer; //science+comms

    //1 player crew
    else if (value == "single" || value == "singlepilot")
        result = CrewPosition::singlePilot;

    //extras
    else if (value == "damagecontrol")
        result = CrewPosition::damageControl;
    else if (value == "powermanagement")
        result = CrewPosition::powerManagement;
    else if (value == "database" || value == "databaseview")
        result = CrewPosition::databaseView;
    else if (value == "altrelay")
        result = CrewPosition::altRelay;
    else if (value == "commsonly")
        result = CrewPosition::commsOnly;
    else if (value == "shiplog")
        result = CrewPosition::shipLog;
    else {
        result = CrewPosition::helmsOfficer;
        return false;
    }

    return true;
}
