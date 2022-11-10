#include "systems/docking.h"
#include "components/docking.h"
#include "components/collision.h"
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
                ship->target_rotation = vec2ToAngle(position->getPosition() - target_position->getPosition());
                if (fabs(angleDifference(ship->target_rotation, position->getRotation())) < 10.0f)
                    ship->impulse_request = -1.f;
                else
                    ship->impulse_request = 0.f;
                ship->warp_request = 0.f;
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
                    if (ship->hull_strength < ship->hull_max)
                    {
                        ship->hull_strength += delta;
                        if (ship->hull_strength > ship->hull_max)
                            ship->hull_strength = ship->hull_max;
                    }
                }

                if (bay && (bay->flags & DockingBay::ShareEnergy)) {
                    auto target_ship = dynamic_cast<SpaceShip*>(*docking_port.target.getComponent<SpaceObject*>());
                    // Derive a base energy request rate from the player ship's maximum
                    // energy capacity.
                    float energy_request = std::min(delta * 10.0f, player->max_energy_level - player->energy_level);

                    // If we're docked with a shipTemplateBasedObject, and that object is
                    // set to share its energy with docked ships, transfer energy from the
                    // mothership to docked ships until the mothership runs out of energy
                    // or the docked ship doesn't require any.
                    if (!target_ship || target_ship->useEnergy(energy_request))
                        ship->energy_level += energy_request;
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
            ship->impulse_request = 0.f;
            ship->warp_request = 0.f;
            break;
        }
    }
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
