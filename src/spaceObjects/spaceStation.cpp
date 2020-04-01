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
: SpaceShip("SpaceStation", 300)
{
    setCollisionPhysics(true, true);
    restocks_scan_probes = true;
    comms_script_name = "comms_station.lua";
    setRadarSignatureInfo(0.2, 0.5, 0.5);

    callsign = "DS" + string(getMultiplayerId());
}

void SpaceStation::applyTemplateValues()
{
    // Collect template values set with the ship template.
    SpaceShip::applyTemplateValues();

    // All ships have a simple scan result of all stations.
    SpaceShip::setScanState(SS_SimpleScan);

    // Ships should avoid colliding with stations if possible.
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
                points += shield_max[n] * 0.1;
            }
            points /= shield_count;
        }
        points += hull_max * 0.1;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

bool SpaceStation::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj))
        return false;
    P<SpaceShip> ship = obj;
    if (!ship)
        return false;
    return true;
}

string SpaceStation::getExportLine()
{
    return "SpaceStation():setTemplate(\"" + template_name + "\"):setFaction(\"" + getFaction() + "\"):setCallSign(\"" + getCallSign() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
}
