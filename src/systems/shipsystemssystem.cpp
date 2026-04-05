#include "shipsystemssystem.h"
#include "multiplayer_server.h"
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
    if (!game_server) return;
    for(auto [entity, system] : sp::ecs::Query<Reactor>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<BeamWeaponSys>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<MissileTubes>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<ManeuveringThrusters>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<ImpulseEngine>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<WarpDrive>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<JumpDrive>())
        updateSystem(entity, system, delta);
    for(auto [entity, system] : sp::ecs::Query<Shields>()) {
        updateSystem(entity, system.front_system, delta);
        if (system.entries.size() > 1)
            updateSystem(entity, system.rear_system, delta);
    }
}

void ShipSystemsSystem::updateSystem(sp::ecs::Entity entity, ShipSystem& system, float delta)
{
    const bool has_coolant = entity.hasComponent<Coolant>();
    // Cap system power request to 100% if a ship lacks both Coolant (no heat
    // generation) and a Reactor (no energy consumption). Otherwise,
    // overpowering the system is free of consequences.
    if (!has_coolant && !entity.hasComponent<Reactor>())
        system.power_request = std::min(system.power_request, 1.0f);

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
