#include "main.h"
#include "mine.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "pathPlanner.h"
#include "random.h"
#include "multiplayer_server.h"
#include "components/collision.h"
#include "components/radar.h"

#include "scriptInterface.h"

#include "i18n.h"

/// A Mine is an explosive weapon that detonates and deals kinetic damage when a SpaceObject collides with its trigger range.
/// Mines can be owned by factions but are triggered by SpaceObjects of any faction can trigger them.
/// Mines can be launched from a SpaceShip's weapon tube or added by a GM or scenario script.
/// When launched from a SpaceShip, the mine has an eject timeout, during which its trigger range is inactive.
/// In 3D views, mines are represented by a particle effect at the center of its trigger range.
/// To create objects with more complex collision mechanics, use an Artifact.
/// Example: mine = Mine():setPosition(1000,1000):onDestruction(this_mine, instigator) print("Tripped a mine!") end)
REGISTER_SCRIPT_SUBCLASS(Mine, SpaceObject)
{
  /// Returns this Mine owner's SpaceObject.
  /// Works only on the server; mine ownership isn't replicated to clients.
  /// Example: mine:getOwner()
  REGISTER_SCRIPT_CLASS_FUNCTION(Mine, getOwner);
  /// Defines a function to call when this Mine is destroyed.
  /// Passes the mine object and the object of the mine's owner/instigator (or nil if there isn't one) to the function.
  /// Example: mine:onDestruction(function(this_mine, instigator) print("Tripped a mine!") end)
  REGISTER_SCRIPT_CLASS_FUNCTION(Mine, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(Mine, "Mine");
Mine::Mine()
: SpaceObject(50, "Mine"), data(MissileWeaponData::getDataFor(MW_Mine))
{
    if (entity) {
        auto& physics = entity.getOrAddComponent<sp::Physics>();
        physics.setCircle(sp::Physics::Type::Sensor, trigger_range);
    }
    triggered = false;
    triggerTimeout = triggerDelay;
    ejectTimeout = 0.0;
    particleTimeout = 0.0;
    setRadarSignatureInfo(0.0, 0.05, 0.0);

    PathPlannerManager::getInstance()->addAvoidObject(this, blastRange * 1.2f);
    if (entity) {
        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.icon = "radar/blip.png";
        trace.min_size = 10;
        trace.max_size = 10;
    }
}

Mine::~Mine()
{
}

void Mine::draw3D()
{
}

void Mine::draw3DTransparent()
{
}

void Mine::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, trigger_range * scale, 3.0, triggered ? glm::u8vec4(255, 0, 0, 128) : glm::u8vec4(255, 255, 255, 128));
}

void Mine::update(float delta)
{
    if (particleTimeout > 0)
    {
        particleTimeout -= delta;
    }else{
        glm::vec3 pos = glm::vec3(getPosition().x, getPosition().y, 0);
        ParticleEngine::spawn(pos, pos + glm::vec3(random(-100, 100), random(-100, 100), random(-100, 100)), glm::vec3(1, 1, 1), glm::vec3(0, 0, 1), 30, 0, 10.0);
        particleTimeout = 0.4;
    }

    auto physics = entity.getComponent<sp::Physics>();

    if (ejectTimeout > 0.0f)
    {
        ejectTimeout -= delta;
        if (physics) physics->setVelocity(vec2FromAngle(getRotation()) * data.speed);
    }else{
        if (physics) physics->setVelocity(glm::vec2(0, 0));
    }
    if (!triggered)
        return;
    triggerTimeout -= delta;
    if (triggerTimeout <= 0)
    {
        explode();
    }
}

void Mine::collide(SpaceObject* target, float force)
{
    if (!game_server || triggered || ejectTimeout > 0.0f)
        return;
    P<SpaceObject> hitObject = target;
    if (!hitObject || !hitObject->canBeTargetedBy(nullptr))
        return;

    triggered = true;
}

void Mine::eject()
{
    ejectTimeout = data.lifetime;
}

void Mine::explode()
{
    DamageInfo info(owner ? owner->entity : sp::ecs::Entity{}, DamageType::Kinetic, getPosition());
    DamageSystem::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, blastRange / 2.0f);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setRadarSignatureInfo(0.0, 0.0, 0.2);

    if (on_destruction.isSet())
    {
        if (info.instigator)
        {
            on_destruction.call<void>(P<Mine>(this), info.instigator);
        }else{
            on_destruction.call<void>(P<Mine>(this));
        }
    }
    destroy();
}

void Mine::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

P<SpaceObject> Mine::getOwner()
{
    if (game_server)
    {
        return owner;
    }

    LOG(ERROR) << "Mine::getOwner(): owner not replicated to clients.";
    return nullptr;
}

std::unordered_map<string, string> Mine::getGMInfo()
{
    std::unordered_map<string, string> ret;

    if (owner)
    {
        ret[trMark("gm_info", "Owner")] = owner->getCallSign();
    }

    ret[trMark("gm_info", "Faction")] = getLocaleFaction();

    return ret;
}
