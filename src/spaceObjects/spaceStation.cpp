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

void SpaceStation::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, radar_trace);
    objectSprite.setPosition(position);
    float sprite_scale = scale * getRadius() * 1.5 / objectSprite.getTextureRect().width;

    if (!long_range)
    {
        sprite_scale *= 0.7;
        drawShieldsOnRadar(window, position, scale, rotation, sprite_scale, true);
    }
    sprite_scale = std::max(0.15f, sprite_scale);
    objectSprite.setScale(sprite_scale, sprite_scale);
    if (my_spaceship)
    {
        if (isEnemy(my_spaceship))
            objectSprite.setColor(sf::Color::Red);
        else if (isFriendly(my_spaceship))
            objectSprite.setColor(sf::Color(128, 255, 128));
        else
            objectSprite.setColor(sf::Color(128, 128, 255));
    }else{
        objectSprite.setColor(factionInfo[getFactionId()]->gm_color);
    }
    window.draw(objectSprite);
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
