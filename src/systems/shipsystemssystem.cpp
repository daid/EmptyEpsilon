#include "shipsystemssystem.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"
#include "components/impulse.h"
#include "components/shields.h"
#include "components/coolant.h"


void ShipSystemsSystem::update(float delta)
{
    for(auto [entity, system] : sp::ecs::Query<Reactor>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<BeamWeaponSys>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<MissileTubes>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<ManeuveringThrusters>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<ImpulseEngine>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<WarpDrive>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<JumpDrive>())
        updateSystem(system, delta, entity.hasComponent<Coolant>());
    for(auto [entity, system] : sp::ecs::Query<Shields>()) {
        updateSystem(system.front_system, delta, entity.hasComponent<Coolant>());
        if (system.entries.size() > 1)
            updateSystem(system.rear_system, delta, entity.hasComponent<Coolant>());
    }
}

void ShipSystemsSystem::updateSystem(ShipSystem& system, float delta, bool has_coolant)
{
    system.health = std::min(1.0f, system.health + delta * system.auto_repair_per_second);

    system.hacked_level = std::max(0.0f, system.hacked_level - delta / unhack_time);
    system.health = std::min(system.health, system.health_max);

    // Add heat to overpowered subsystems.
    if (has_coolant)
        system.addHeat(delta * system.getHeatingDelta() * system.heat_add_rate_per_second);

    if (system.power_request > system.power_level)
    {
        system.power_level += delta * system.power_change_rate_per_second;
        if (system.power_level > system.power_request)
            system.power_level = system.power_request;
    }
    else if (system.power_request < system.power_level)
    {
        system.power_level -= delta * system.power_change_rate_per_second;
        if (system.power_level < system.power_request)
            system.power_level = system.power_request;
    }
}
