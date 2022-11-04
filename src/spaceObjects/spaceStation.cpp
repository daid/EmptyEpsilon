#include "spaceObjects/explosionEffect.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
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
    restocks_scan_probes = true;
    restocks_missiles_docked = true;
    comms_script_name = "comms_station.lua";
    setRadarSignatureInfo(0.2, 0.5, 0.5);

    callsign = "DS" + string(getMultiplayerId());
}

void SpaceStation::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    float sprite_scale = scale * getRadius() * 1.5f / 32;

    if (!long_range)
    {
        sprite_scale *= 0.7f;
        drawShieldsOnRadar(renderer, position, scale, rotation, sprite_scale, true);
    }
}

void SpaceStation::applyTemplateValues()
{
    PathPlannerManager::getInstance()->addAvoidObject(this, getRadius() * 1.5f);
}

void SpaceStation::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.0, 0.4, 0.4);

    if (info.instigator)
    {
        float points = 0;
        if (shield_count > 0)
        {
            for(int n=0; n<shield_count; n++)
            {
                points += shield_max[n] * 0.1f;
            }
            points /= shield_count;
        }
        points += hull_max * 0.1f;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

DockStyle SpaceStation::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj))
        return DockStyle::None;
    P<SpaceShip> ship = obj;
    if (!ship)
        return DockStyle::None;
    return DockStyle::External;
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
