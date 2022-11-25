#include "systems/docking.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "components/reactor.h"
#include "components/hull.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/cpuShip.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

DockingSystem::DockingSystem()
{
    sp::CollisionSystem::addHandler(this);
}

void DockingSystem::update(float delta)
{
    if (!game_server) return;

    for(auto [entity, docking_port, position, obj] : sp::ecs::Query<DockingPort, sp::ecs::optional<sp::Position>, SpaceObject*>()) {
        SpaceShip* ship = dynamic_cast<SpaceShip*>(obj);
        PlayerSpaceship* player = dynamic_cast<PlayerSpaceship*>(obj);
        if (!ship) continue;
        sp::Position* target_position;
        switch(docking_port.state) {
        case DockingPort::State::NotDocking:
            break;
        case DockingPort::State::Docking:
            if (!docking_port.target || !(target_position = docking_port.target.getComponent<sp::Position>())) {
                docking_port.state = DockingPort::State::NotDocking;
            } else {
                auto engine = entity.getComponent<ImpulseEngine>();
                auto warp = entity.getComponent<WarpDrive>();
                ship->target_rotation = vec2ToAngle(position->getPosition() - target_position->getPosition());
                if (engine) {
                    if (fabs(angleDifference(ship->target_rotation, position->getRotation())) < 10.0f)
                        engine->request = -1.f;
                    else
                        engine->request = 0.f;
                }
                if (warp)
                    warp->request = 0;
            }
            break;
        case DockingPort::State::Docked:
            if (!docking_port.target || !(target_position = docking_port.target.getComponent<sp::Position>()))
            {
                docking_port.state = DockingPort::State::NotDocking;
                if (!position) { // Internal docking and our bay is destroyed. So, destroy ourselves as well.
                    entity.destroy();
                }
            }else{
                if (position) {
                    position->setPosition(target_position->getPosition() + rotateVec2(docking_port.docked_offset, target_position->getRotation()));
                    ship->target_rotation = vec2ToAngle(position->getPosition() - target_position->getPosition());
                }

                auto bay = docking_port.target.getComponent<DockingBay>();
                if (bay && (bay->flags & DockingBay::Repair))  //Check if what we are docked to allows hull repairs, and if so, do it.
                {
                    auto hull = entity.getComponent<Hull>();
                    if (hull && hull->current < hull->max)
                    {
                        hull->current += delta;
                        if (hull->current > hull->max)
                            hull->current = hull->max;
                    }
                }

                if (bay && (bay->flags & DockingBay::ShareEnergy)) {
                    auto my_reactor = entity.getComponent<Reactor>();
                    if (my_reactor) {
                        auto other_reactor = docking_port.target.getComponent<Reactor>();
                        // Derive a base energy request rate from the player ship's maximum
                        // energy capacity.
                        float energy_request = std::min(delta * 10.0f, my_reactor->max_energy - my_reactor->energy);

                        // If we're docked with a shipTemplateBasedObject, and that object is
                        // set to share its energy with docked ships, transfer energy from the
                        // mothership to docked ships until the mothership runs out of energy
                        // or the docked ship doesn't require any.
                        if (!other_reactor || other_reactor->use_energy(energy_request))
                            my_reactor->energy += energy_request;
                    }
                }

                if (player && bay && (bay->flags & DockingBay::RestockProbes)) {
                    // If a shipTemplateBasedObject and is allowed to restock
                    // scan probes with docked ships.
                    if (player->scan_probe_stock < player->max_scan_probes)
                    {
                        player->scan_probe_recharge += delta;

                        if (player->scan_probe_recharge > player->scan_probe_charge_time)
                        {
                            player->scan_probe_stock += 1;
                            player->scan_probe_recharge = 0.0;
                        }
                    }
                }

                //recharge missiles of CPU ships docked to station. Can be disabled
                if (!player && bay && (bay->flags & DockingBay::RestockMissiles)) {
                    auto cpu = dynamic_cast<CpuShip*>(ship);
                    if (cpu) {
                        bool needs_missile = false;

                        for(int n=0; n<MW_Count; n++)
                        {
                            if  (ship->weapon_storage[n] < ship->weapon_storage_max[n])
                            {
                                if (cpu->missile_resupply >= cpu->missile_resupply_time)
                                {
                                    cpu->weapon_storage[n] += 1;
                                    cpu->missile_resupply = 0.0;
                                    break;
                                }
                                else
                                    needs_missile = true;
                            }
                        }

                        if (needs_missile)
                            cpu->missile_resupply += delta;
                    }
                }
            }

            auto engine = entity.getComponent<ImpulseEngine>();
            if (engine)
                engine->request = 0.f;
            auto warp = entity.getComponent<WarpDrive>();
            if (warp)
                warp->request = 0;
            break;
        }
    }
}

bool DockingSystem::canStartDocking(sp::ecs::Entity entity)
{
    auto port = entity.getComponent<DockingPort>();
    if (!port) return false;
    if (port->state != DockingPort::State::NotDocking) return false;
    auto warp = entity.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f) return false;
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f) return false;
    return true;
}

void DockingSystem::collision(sp::ecs::Entity a, sp::ecs::Entity b, float force)
{
    auto port = a.getComponent<DockingPort>();
    if (port && port->state == DockingPort::State::Docking && port->target == b) {
        auto position = a.getComponent<sp::Position>();
        auto other_position = b.getComponent<sp::Position>();
        auto ship = dynamic_cast<SpaceShip*>(*a.getComponent<SpaceObject*>());

        if (ship && position && other_position && fabs(angleDifference(ship->target_rotation, position->getRotation())) < 10.0f)
        {
            port->state = DockingPort::State::Docked;
            auto bay = b.getComponent<DockingBay>();
            port->docked_offset = rotateVec2(position->getPosition() - other_position->getPosition(), -other_position->getRotation());
            float length = glm::length(port->docked_offset);
            port->docked_offset = port->docked_offset / length * (length + 2.0f);

            if (bay && port->canDockOn(*bay) == DockingStyle::Internal)
                a.removeComponent<sp::Position>();
        }
    }
}


void DockingSystem::requestDock(sp::ecs::Entity entity, sp::ecs::Entity target)
{
    if (!canStartDocking(entity))
        return;

    auto docking_port = entity.getComponent<DockingPort>();
    if (!docking_port || docking_port->state != DockingPort::State::NotDocking) return;
    if (!target) return;
    auto bay = target.getComponent<DockingBay>();
    if (!bay || docking_port->canDockOn(*bay) == DockingStyle::None) return;
    auto position = entity.getComponent<sp::Position>();
    if (position) return;
    auto target_position = target.getComponent<sp::Position>();
    if (target_position) return;
    auto target_physics = target.getComponent<sp::Physics>();
    if (target_physics) return;

    if (glm::length(position->getPosition() - target_position->getPosition()) > 1000.0f + target_physics->getSize().x)
        return;

    docking_port->state = DockingPort::State::Docking;
    docking_port->target = target;
    auto warp = entity.getComponent<WarpDrive>();
    if (warp) warp->request = 0;
}

void DockingSystem::requestUndock(sp::ecs::Entity entity)
{
    auto docking_port = entity.getComponent<DockingPort>();
    if (!docking_port || docking_port->state != DockingPort::State::Docked) return;
    auto impulse = entity.getComponent<ImpulseEngine>();
    if (impulse && impulse->get_system_effectiveness() < 0.1f) return;

    docking_port->state = DockingPort::State::NotDocking;
    if (impulse) impulse->request = 0.5;
}

void DockingSystem::abortDock(sp::ecs::Entity entity)
{
    auto docking_port = entity.getComponent<DockingPort>();
    if (!docking_port || docking_port->state != DockingPort::State::Docking) return;

    docking_port->state = DockingPort::State::NotDocking;
    auto engine = entity.getComponent<ImpulseEngine>();
    if (engine) engine->request = 0.f;
    auto warp = entity.getComponent<WarpDrive>();
    if (warp) warp->request = 0;

    auto obj = entity.getComponent<SpaceObject*>();
    if (obj && *obj) {
        auto ship = dynamic_cast<SpaceShip*>(*obj);
        if (ship)
            ship->target_rotation = ship->getRotation();
    }
}
