#include "warpJammer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"

/// A warp jammer.
REGISTER_SCRIPT_SUBCLASS(WarpJammer, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, setRange);
    /// Set a function that will be called if the warp jammer is taking damage.
    /// First argument given to the function will be the warp jammer, the second the instigator SpaceObject (or nil).
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, onTakingDamage);
    /// Set a function that will be called if the warp jammer is destroyed by taking damage.
    /// First argument given to the function will be the warp jammer, the second the instigator SpaceObject that gave the final blow (or nil).
    REGISTER_SCRIPT_CLASS_FUNCTION(WarpJammer, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(WarpJammer, "WarpJammer");

PVector<WarpJammer> WarpJammer::jammer_list;

WarpJammer::WarpJammer()
: SpaceObject(100, "WarpJammer")
{
    range = 7000.0;
    hull = 50;

    jammer_list.push_back(this);
    setRadarSignatureInfo(0.05, 0.5, 0.0);

    registerMemberReplication(&range);

    model_info.setData("shield_generator");
}

// Due to a suspected compiler bug this desconstructor needs to be explicity defined
WarpJammer::~WarpJammer()
{
}

void WarpJammer::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    sf::Color color(200, 150, 100);
    if (my_spaceship && my_spaceship->isEnemy(this))
        color = sf::Color(255, 0, 0);
    renderer.drawSprite("radar/blip.png", position, 20, color);

    if (long_range)
    {
        color = sf::Color(200, 150, 100, 64);
        if (my_spaceship && my_spaceship->isEnemy(this))
            color = sf::Color(255, 0, 0, 64);
        renderer.drawCircleOutline(position, range*scale, 2.0, color);
    }
}

void WarpJammer::takeDamage(float damage_amount, DamageInfo info)
{
    if (info.type == DT_EMP)
        return;
    hull -= damage_amount;
    if (hull <= 0)
    {
        P<ExplosionEffect> e = new ExplosionEffect();
        e->setSize(getRadius());
        e->setPosition(getPosition());
        e->setRadarSignatureInfo(0.5, 0.5, 0.1);

        if (on_destruction.isSet())
        {
            if (info.instigator)
            {
                on_destruction.call<void>(P<WarpJammer>(this), P<SpaceObject>(info.instigator));
            } else {
                on_destruction.call<void>(P<WarpJammer>(this));
            }
        }

        destroy();
    } else {
        if (on_taking_damage.isSet())
        {
            if (info.instigator)
            {
                on_taking_damage.call<void>(P<WarpJammer>(this), P<SpaceObject>(info.instigator));
            } else {
                on_taking_damage.call<void>(P<WarpJammer>(this));
            }
        }
    }
}

bool WarpJammer::isWarpJammed(glm::vec2 position)
{
    foreach(WarpJammer, wj, jammer_list)
    {
        if (glm::length2(wj->getPosition() - position) < wj->range * wj->range)
            return true;
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
        float f = glm::dot(startEndDiff, wj->getPosition() - start) / startEndLength;
        if (f < 0.0)
            f = 0;
        glm::vec2 q = start + startEndDiff / startEndLength * f;
        if (glm::length2(q - wj->getPosition()) < wj->range*wj->range)
        {
            if (!first_jammer || f < first_jammer_f)
            {
                first_jammer = wj;
                first_jammer_f = f;
                first_jammer_q = q;
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
    this->on_taking_damage = callback;
}

void WarpJammer::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

string WarpJammer::getExportLine()
{
    string ret = "WarpJammer():setFaction(\"" + getFaction() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    if (getRange()!=7000.0) {
	    ret += ":setRange("+string(getRange())+")";
    }
    return ret;
}
