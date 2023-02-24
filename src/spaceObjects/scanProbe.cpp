#include <graphics/opengl.h>
#include "scanProbe.h"
#include "explosionEffect.h"
#include "main.h"
#include "random.h"
#include "components/hull.h"

#include "scriptInterface.h"

/// A ScanProbe deploys a short-range radar with a limited lifetime at a high speed to a specific point.
/// ScanProbes can be targeted and destroyed by hostiles.
/// It's typically launched by the relay officer and can be linked to the science radar, but can also be created by scripts.
/// PlayerSpaceships have a limited stock of ScanProbes typically replenished automatically when docked to a SpaceStation or SpaceShip with the ScanProbe restocking feature enabled.
/// Example: probe = ScanProbe():setSpeed(1500):setLifetime(60 * 30):setTarget(10000,10000):onArrival(function() print("Probe arrived!") end)
REGISTER_SCRIPT_SUBCLASS(ScanProbe, SpaceObject)
{
    /// Sets this ScanProbe's speed.
    /// Probes move at a fixed rate of speed and ignore collisions and physics while moving.
    /// Defaults to 1000 (1U/second).
    /// Example: probe:setSpeed(2000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setSpeed);
    /// Returns this ScanProbe's speed.
    /// Example: probe:getSpeed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getSpeed);
    /// Sets this ScanProbe's remaining lifetime, in seconds.
    /// Defaults to 600 seconds (10 minutes).
    /// Example: probe:setLifetime(60 * 5) -- sets the lifetime to 5 minutes
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setLifetime);
    /// Returns this ScanProbe's remaining lifetime.
    /// Example: probe:getLifetime()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getLifetime);
    /// Sets this ScanProbe's target coordinates.
    /// If the probe has reached its target, ScanProbe:setTarget() moves it again toward the new target coordinates.
    /// Example: probe:setTarget(1000,5000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setTarget);
    /// Returns this ScanProbe's target coordinates.
    /// Example: targetX,targetY = probe:getTarget()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getTarget);
    /// Sets this ScanProbe's owner SpaceObject.
    /// Example: probe:setOwner(owner)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setOwner);
    /// Returns this ScanProbe's owner SpaceObject.
    /// Example: probe:getOwner()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getOwner);
    /// Defines a function to call when this ScanProbe arrives to its target coordinates.
    /// Passes the probe and position as arguments to the function.
    /// Example: probe:onArrival(function(this_probe, coords) print("Probe arrived!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onArrival);
    /// Defines a function to call when this ScanProbe's lifetime expires.
    /// Passes the probe as an argument to the function.
    /// Example: probe:onExpiration(function(this_probe) print("Probe expired!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onExpiration);
    /// Defines a function to call when this ScanProbe is destroyed by damage.
    /// Passes the probe and instigator as arguments to the function.
    /// Example: probe:onDestruction(function(this_probe, instigator) print("Probe destroyed!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(ScanProbe, "ScanProbe");
ScanProbe::ScanProbe()
: SpaceObject(100, "ScanProbe"),
  probe_speed(1000.0f)
{
    // Probe persists for 10 minutes.
    lifetime = 60 * 10;
    // Probe has not arrived yet.
    has_arrived = false;

    registerMemberReplication(&probe_speed, 0.1);
    registerMemberReplication(&target_position, 0.1);
    registerMemberReplication(&lifetime, 60.0);

    // Give the probe a small electrical radar signature.
    setRadarSignatureInfo(0.0, 0.2, 0.0);

    // Randomly select a probe model.
    switch(irandom(1, 3))
    {
        case 1:
        {
            model_info.setData("SensorBuoyMKI");
            break;
        }
        case 2:
        {
            model_info.setData("SensorBuoyMKII");
            break;
        }
        default:
        {
            model_info.setData("SensorBuoyMKIII");
        }
    }

    // Assign a generic callsign.
    setCallSign(string(getMultiplayerId()) + "P");

    if (entity) {
        auto hull = entity.addComponent<Hull>();
        hull.max = hull.current = 1;
        entity.getOrAddComponent<ShareShortRangeRadar>();
    }
}

// Due to a suspected compiler bug, this deconstructor must be explicitly
// defined.
ScanProbe::~ScanProbe()
{
}

void ScanProbe::setSpeed(float probe_speed)
{
    this->probe_speed = probe_speed > 0.0f ? probe_speed : 0.0f;
}

float ScanProbe::getSpeed()
{
    return this->probe_speed;
}

void ScanProbe::setLifetime(float lifetime)
{
    this->lifetime = lifetime > 0.0f ? lifetime : 0.0f;
}

float ScanProbe::getLifetime()
{
    return this->lifetime;
}

void ScanProbe::update(float delta)
{
    // Tick down lifetime until expiration, then destroy the probe.
    lifetime -= delta;

    if (lifetime <= 0.0f)
    {
        // Fire the onExpiration callback, if set.
        if (on_expiration.isSet())
        {
            on_expiration.call<void>(P<ScanProbe>(this));
        }

        destroy();
    }

    // The probe moves in a straight line to its destination, independent of
    // physics and at a fixed rate of speed.
    auto diff = target_position - getPosition();
    float movement = delta * probe_speed;
    float distance = glm::length(diff);

    // If the probe's outer radius hasn't reached the target position ...
    if (distance > 100.0f)
    {
        // The probe is still in transit.
        has_arrived = false;

        // Normalize the diff.
        auto v = glm::normalize(diff);

        // Update the probe's heading.
        setHeading(vec2ToAngle(v) + 90.0f);

        // Move toward the target position at the given rate of speed.
        // However, don't overshoot the target if traveling so fast that the
        // movement per tick is greater than the distance to the destination.
        if (distance < movement)
        {
            movement = distance;
        }

        setPosition(getPosition() + v * movement);
    }
    else if (!has_arrived)
    {
        // The probe arrived to its destination.
        has_arrived = true;

        // Fire the onArrival callback, if set.
        if (on_arrival.isSet())
        {
            on_arrival.call<void>(P<ScanProbe>(this), getPosition().x, getPosition().y);
        }
    }
}

bool ScanProbe::canBeTargetedBy(sp::ecs::Entity other)
{
    // The probe cannot be targeted until it reaches its destination.
    return glm::length2(getTarget() - getPosition()) < 100.0f*100.0f;
}

void ScanProbe::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    // All probes use the same green icon on radar.
    renderer.drawSprite("radar/probe.png", position, 10, glm::u8vec4(96, 192, 128, 255));
}

void ScanProbe::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    SpaceObject::drawOnGMRadar(renderer, position, scale, rotation, long_range);

    if (long_range)
    {
        // Draw a circle on the GM radar representing the probe's fixed 5U
        // radar radius.
        renderer.drawCircleOutline(position, 5000*scale, 3.0, glm::u8vec4(255, 255, 255, 64));
    }
}

void ScanProbe::setOwner(sp::ecs::Entity owner)
{
    if (!owner)
    {
        return;
    }

    // Set the probe's faction and ship ownership based on the passed object.
    auto f = owner.getComponent<Faction>();
    if (f)
        entity.getOrAddComponent<Faction>().entity = f->entity;
    entity.getOrAddComponent<AllowRadarLink>().owner = owner;
}

void ScanProbe::onArrival(ScriptSimpleCallback callback)
{
    this->on_arrival = callback;
}

void ScanProbe::onDestruction(ScriptSimpleCallback callback)
{
    //TODO
}

void ScanProbe::onExpiration(ScriptSimpleCallback callback)
{
    this->on_expiration = callback;
}
