#include "spaceObjects/explosionEffect.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/collision.h"
#include "components/hull.h"
#include "components/shields.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "mesh.h"
#include "main.h"
#include "pathPlanner.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(SpaceStation, ShipTemplateBasedObject)
{
}

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: ShipTemplateBasedObject(300, "SpaceStation")
{
    comms_script_name = "comms_station.lua";
    setRadarSignatureInfo(0.2, 0.5, 0.5);

    callsign = "DS" + string(getMultiplayerId());

    if (entity) {
        entity.getOrAddComponent<sp::Physics>().setCircle(sp::Physics::Type::Static, 300);

        auto& bay = entity.getOrAddComponent<DockingBay>();
        bay.flags |= DockingBay::RestockMissiles | DockingBay::RestockProbes;
    }
}

void SpaceStation::applyTemplateValues()
{
    PathPlannerManager::getInstance()->addAvoidObject(this, getRadius() * 1.5f);
}

string SpaceStation::getExportLine()
{
    string ret = "SpaceStation()";
    ret += ":setTemplate(\"" + template_name + "\")";

    if (getShortRangeRadarRange() != ship_template->short_range_radar_range)
    {
        ret += ":setShortRangeRadarRange(" + string(getShortRangeRadarRange(), 0) + ")";
    }

    if (getLongRangeRadarRange() != ship_template->long_range_radar_range)
    {
        ret += ":setLongRangeRadarRange(" + string(getLongRangeRadarRange(), 0) + ")";
    }

    ret += ":setFaction(\"" + getFaction() + "\")";
    ret += ":setCallSign(\"" + getCallSign() + "\")";
    ret += ":setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";

    return ret;
}
