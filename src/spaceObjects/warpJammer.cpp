#include "warpJammer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/collision.h"
#include "explosionEffect.h"
#include "components/hull.h"
#include "main.h"

#include "scriptInterface.h"

/// A WarpJammer restricts the ability of any SpaceShips to use warp or jump drives within its radius.
/// WarpJammers can be targeted, damaged, and destroyed.
/// Example: jammer = WarpJammer():setPosition(1000,1000):setRange(10000):setHull(20)
REGISTER_SCRIPT_SUBCLASS(WarpJammer, SpaceObject)
{
    /// Returns this WarpJammer's jamming range, represented on radar as a circle with jammer in the middle.
    /// No warp/jump travel is possible within this radius.
    /// Example: jammer:getRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, getRange);
    /// Sets this WarpJammer's jamming radius.
    /// No warp/jump travel is possible within this radius.
    /// Defaults to 7000.0.
    /// Example: jammer:setRange(10000) -- sets a 10U jamming radius 
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, setRange);

    /// Returns this WarpJammer's hull points.
    /// Example: jammer:getHull()
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, getHull);
    /// Sets this WarpJammer's hull points.
    /// Defaults to 50
    /// Example: jammer:setHull(20)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, setHull);

    /// Defines a function to call when this WarpJammer takes damage.
    /// Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
    /// Example: jammer:onTakingDamage(function(this_jammer,instigator) print("Jammer damaged!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, onTakingDamage);
    /// Defines a function to call when the WarpJammer is destroyed by taking damage.
    /// Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
    /// Example: jammer:onDestruction(function(this_jammer,instigator) print("Jammer destroyed!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(WarpJammer, "WarpJammer");

PVector<WarpJammer> WarpJammer::jammer_list;

WarpJammer::WarpJammer()
: SpaceObject(100, "WarpJammer")
{
    range = 7000.0;

    jammer_list.push_back(this);
    setRadarSignatureInfo(0.05, 0.5, 0.0);

    registerMemberReplication(&range);

    model_info.setData("shield_generator");

    if (entity) {
        auto hull = entity.addComponent<Hull>();
        hull.max = hull.current = 50.0;
    }
}

// Due to a suspected compiler bug this desconstructor needs to be explicity defined
WarpJammer::~WarpJammer()
{
}

void WarpJammer::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    glm::u8vec4 color(200, 150, 100, 255);
    if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
        color = glm::u8vec4(255, 0, 0, 255);
    renderer.drawSprite("radar/blip.png", position, 20, color);

    if (long_range)
    {
        color = glm::u8vec4(200, 150, 100, 64);
        if (my_spaceship && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
            color = glm::u8vec4(255, 0, 0, 64);
        renderer.drawCircleOutline(position, range*scale, 2.0, color);
    }
}

bool WarpJammer::isWarpJammed(sp::ecs::Entity entity)
{
    if (auto transform = entity.getComponent<sp::Transform>()) {
        auto position = transform->getPosition();
        foreach(WarpJammer, wj, jammer_list)
        {
            if (glm::length2(wj->getPosition() - position) < wj->range * wj->range)
                return true;
        }
    }
    return false;
}

glm::vec2 WarpJammer::getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    P<WarpJammer> first_jammer;
    float first_jammer_f = startEndLength;
    glm::vec2 first_jammer_q{0, 0};
    foreach(WarpJammer, wj, jammer_list)
    {
        float f_inf = glm::dot(startEndDiff, wj->getPosition() - start) / startEndLength;
	float f_limited = std::min(std::max(0.0f, f_inf), startEndLength);
        glm::vec2 q_limited = start + startEndDiff / startEndLength * f_limited;
        if (glm::length2(q_limited - wj->getPosition()) < wj->range*wj->range)
        {
            if (!first_jammer || f_limited < first_jammer_f)
            {
                first_jammer = wj;
                first_jammer_f = f_limited;
                first_jammer_q = start + startEndDiff / startEndLength * f_inf;
            }
        }
    }
    if (!first_jammer)
        return end;

    float d = glm::length(first_jammer_q - first_jammer->getPosition());
    return first_jammer_q + glm::normalize(start - end) * sqrtf(first_jammer->range * first_jammer->range - d * d);
}

void WarpJammer::onTakingDamage(ScriptSimpleCallback callback)
{
    //TODO
}

void WarpJammer::onDestruction(ScriptSimpleCallback callback)
{
    //TODO
}

string WarpJammer::getExportLine()
{
    string ret = "WarpJammer():setFaction(\"" + getFaction() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    if (getRange() != 7000.0f) {
	    ret += ":setRange("+string(getRange())+")";
    }
    return ret;
}
