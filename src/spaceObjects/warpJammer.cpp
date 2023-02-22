#include "warpJammer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/collision.h"
#include "components/warpdrive.h"
#include "explosionEffect.h"
#include "components/hull.h"
#include "main.h"

#include "scriptInterface.h"

/// A WarpJammer restricts the ability of any SpaceShips to use warp or jump drives within its radius.
/// WarpJammers can be targeted, damaged, and destroyed.
/// Example: jammer = WarpJammer():setPosition(1000,1000):setRange(10000):setHull(20)
REGISTER_SCRIPT_SUBCLASS_NAMED(WarpJammerObject, SpaceObject, "WarpJammer")
{
    /// Returns this WarpJammer's jamming range, represented on radar as a circle with jammer in the middle.
    /// No warp/jump travel is possible within this radius.
    /// Example: jammer:getRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, getRange);
    /// Sets this WarpJammer's jamming radius.
    /// No warp/jump travel is possible within this radius.
    /// Defaults to 7000.0.
    /// Example: jammer:setRange(10000) -- sets a 10U jamming radius 
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, setRange);

    /// Returns this WarpJammer's hull points.
    /// Example: jammer:getHull()
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, getHull);
    /// Sets this WarpJammer's hull points.
    /// Defaults to 50
    /// Example: jammer:setHull(20)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, setHull);

    /// Defines a function to call when this WarpJammer takes damage.
    /// Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
    /// Example: jammer:onTakingDamage(function(this_jammer,instigator) print("Jammer damaged!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, onTakingDamage);
    /// Defines a function to call when the WarpJammer is destroyed by taking damage.
    /// Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
    /// Example: jammer:onDestruction(function(this_jammer,instigator) print("Jammer destroyed!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammerObject, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(WarpJammerObject, "WarpJammer");

WarpJammerObject::WarpJammerObject()
: SpaceObject(100, "WarpJammer")
{
    setRadarSignatureInfo(0.05, 0.5, 0.0);

    model_info.setData("shield_generator");

    if (entity) {
        auto hull = entity.addComponent<Hull>();
        hull.max = hull.current = 50.0;
        entity.addComponent<WarpJammer>().range = 7000.0;
    }
}

// Due to a suspected compiler bug this desconstructor needs to be explicity defined
WarpJammerObject::~WarpJammerObject()
{
}

void WarpJammerObject::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    glm::u8vec4 color(200, 150, 100, 255);
    if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
        color = glm::u8vec4(255, 0, 0, 255);
    renderer.drawSprite("radar/blip.png", position, 20, color);

    if (long_range)
    {
        if (auto jammer = entity.getComponent<WarpJammer>()) {
            color = glm::u8vec4(200, 150, 100, 64);
            if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
                color = glm::u8vec4(255, 0, 0, 64);
            renderer.drawCircleOutline(position, jammer->range*scale, 2.0, color);
        }
    }
}

void WarpJammerObject::onTakingDamage(ScriptSimpleCallback callback)
{
    //TODO
}

void WarpJammerObject::onDestruction(ScriptSimpleCallback callback)
{
    //TODO
}

string WarpJammerObject::getExportLine()
{
    string ret = "WarpJammer():setFaction(\"" + getFaction() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    if (getRange() != 7000.0f) {
	    ret += ":setRange("+string(getRange())+")";
    }
    return ret;
}
