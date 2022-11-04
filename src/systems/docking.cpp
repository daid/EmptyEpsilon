#include "systems/docking.h"
#include "components/docking.h"
#include "ecs/query.h"


void DockingSystem::update(float delta)
{
/*  ==Spaceship

if (bool(physics) != (docked_style != DockStyle::Internal))
    {
        if (docked_style == DockStyle::Internal) {
            entity.removeComponent<sp::Physics>();
            physics = nullptr;
        } else if (ship_template) {
            ship_template->setCollisionData(this);
        }
    }

    if (game_server)
    {
        if (docking_state == DS_Docking)
        {
            if (!docking_target)
                docking_state = DS_NotDocking;
            else
                target_rotation = vec2ToAngle(getPosition() - docking_target->getPosition());
            if (fabs(angleDifference(target_rotation, getRotation())) < 10.0f)
                impulse_request = -1.f;
            else
                impulse_request = 0.f;
        }
        if (docking_state == DS_Docked)
        {
            if (!docking_target)
            {
                docking_state = DS_NotDocking;
                docked_style = DockStyle::None;
            }else{
                setPosition(docking_target->getPosition() + rotateVec2(docking_offset, docking_target->getRotation()));
                target_rotation = vec2ToAngle(getPosition() - docking_target->getPosition());

                P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
                if (docked_with_template_based && docked_with_template_based->repair_docked)  //Check if what we are docked to allows hull repairs, and if so, do it.
                {
                    if (hull_strength < hull_max)
                    {
                        hull_strength += delta;
                        if (hull_strength > hull_max)
                            hull_strength = hull_max;
                    }
                }
            }
            impulse_request = 0.f;
        }
        if ((docking_state == DS_Docked) || (docking_state == DS_Docking))
            warp_request = 0;
    }

    ==PlayerShip

    // Docking actions.
    if (docking_state == DS_Docked)
    {
        P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
        P<SpaceShip> docked_with_ship = docking_target;

        // Derive a base energy request rate from the player ship's maximum
        // energy capacity.
        float energy_request = std::min(delta * 10.0f, max_energy_level - energy_level);

        // If we're docked with a shipTemplateBasedObject, and that object is
        // set to share its energy with docked ships, transfer energy from the
        // mothership to docked ships until the mothership runs out of energy
        // or the docked ship doesn't require any.
        if (docked_with_template_based && docked_with_template_based->shares_energy_with_docked)
        {
            if (!docked_with_ship || docked_with_ship->useEnergy(energy_request))
                energy_level += energy_request;
        }

        // If a shipTemplateBasedObject and is allowed to restock
        // scan probes with docked ships.
        if (docked_with_template_based && docked_with_template_based->restocks_scan_probes)
        {
            if (scan_probe_stock < max_scan_probes)
            {
                scan_probe_recharge += delta;

                if (scan_probe_recharge > scan_probe_charge_time)
                {
                    scan_probe_stock += 1;
                    scan_probe_recharge = 0.0;
                }
            }
        }
    }else{
        scan_probe_recharge = 0.0;
    }

    ==CpuShip

    //recharge missiles of CPU ships docked to station. Can be disabled setting the restocks_missiles_docked flag to false.
    if (docking_state == DS_Docked)
    {
        P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
        P<SpaceShip> docked_with_ship = docking_target;

        if (docked_with_template_based && docked_with_template_based->restocks_missiles_docked)
        {
            bool needs_missile = 0;

            for(int n=0; n<MW_Count; n++)
            {
                if  (weapon_storage[n] < weapon_storage_max[n])
                {
                    if (missile_resupply >= missile_resupply_time)
                    {
                        weapon_storage[n] += 1;
                        missile_resupply = 0.0;
                        break;
                    }
                    else
                        needs_missile = 1;
                }
            }

            if (needs_missile)
                missile_resupply += delta;
        }
    }
*/
}

/*
Collision:
    if (docking_state == DS_Docking && fabs(angleDifference(target_rotation, getRotation())) < 10.0f)
    {
        P<SpaceObject> dock_object = other;
        if (dock_object == docking_target)
        {
            docking_state = DS_Docked;
            docked_style = docking_target->canBeDockedBy(this);
            docking_offset = rotateVec2(getPosition() - other->getPosition(), -other->getRotation());
            float length = glm::length(docking_offset);
            docking_offset = docking_offset / length * (length + 2.0f);
        }
    }
*/