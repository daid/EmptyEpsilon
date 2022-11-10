#include "systems/impulse.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/warpjammer.h"
#include "ecs/query.h"


void ImpulseSystem::update(float delta)
{
    //TODO: Turn this into better individual systems
    //TODO: This crashes if the object is not a ship
    for(auto [entity, impulse, physics, obj] : sp::ecs::Query<ImpulseEngine, sp::Physics, SpaceObject*>())
    {
        SpaceShip* ship = dynamic_cast<SpaceShip*>(obj);
        //Here we want to have max speed at 100% impulse, and max reverse speed at -100% impulse
        float cap_speed = impulse.max_speed_forward;
        
        if(impulse.actual < 0 && impulse.max_speed_reverse <= 0.01f)
        {
            impulse.actual = 0; //we could get stuck with a ship with no reverse speed, not being able to accelerate
        }
        if(impulse.actual < 0) 
        {
            cap_speed = impulse.max_speed_reverse;
        }
        if ((ship->has_jump_drive && ship->jump_delay > 0) || (ship->has_warp_drive && ship->warp_request > 0))
        {
            if (WarpJammer::isWarpJammed(ship->getPosition()))
            {
                ship->jump_delay = 0;
                ship->warp_request = 0;
            }
        }
        if (ship->has_jump_drive && ship->jump_delay > 0)
        {
            if (impulse.actual > 0.0f)
            {
                if (cap_speed > 0)
                    impulse.actual -= delta * (impulse.acceleration_reverse / cap_speed);
                if (impulse.actual < 0.0f)
                    impulse.actual = 0.f;
            }
            if (impulse.actual < 0.0f)
            {
                if (cap_speed > 0)
                    impulse.actual += delta * (impulse.acceleration_forward / cap_speed);
                if (impulse.actual > 0.0f)
                    impulse.actual = 0.f;
            }
            if (ship->current_warp > 0.0f)
            {
                ship->current_warp -= delta;
                if (ship->current_warp < 0.0f)
                    ship->current_warp = 0.f;
            }
            ship->jump_delay -= delta * ship->getSystemEffectiveness(SYS_JumpDrive);
            if (ship->jump_delay <= 0.0f)
            {
                ship->executeJump(ship->jump_distance);
                ship->jump_delay = 0.f;
            }
        }else if (ship->has_warp_drive && (ship->warp_request > 0 || ship->current_warp > 0))
        {
            if (impulse.actual > 0.0f)
            {
                if (cap_speed > 0)
                    impulse.actual -= delta * (impulse.acceleration_reverse / cap_speed);
                if (impulse.actual < 0.0f)
                    impulse.actual = 0.0f;
            }else if (impulse.actual < 0.0f)
            {
                if (cap_speed > 0)
                    impulse.actual += delta * (impulse.acceleration_forward / cap_speed);
                if (impulse.actual > 0.0f)
                    impulse.actual = 0.0f;
            }else{
                if (ship->current_warp < ship->warp_request)
                {
                    ship->current_warp += delta / ship->warp_charge_time;
                    if (ship->current_warp > ship->warp_request)
                        ship->current_warp = ship->warp_request;
                }else if (ship->current_warp > ship->warp_request)
                {
                    ship->current_warp -= delta / ship->warp_decharge_time;
                    if (ship->current_warp < ship->warp_request)
                        ship->current_warp = ship->warp_request;
                }
            }
        }else{
            if (ship->has_jump_drive)
            {
                float f = ship->getJumpDriveRechargeRate();
                if (f > 0)
                {
                    if (ship->jump_drive_charge < ship->jump_drive_max_distance)
                    {
                        float extra_charge = (delta / ship->jump_drive_charge_time * ship->jump_drive_max_distance) * f;
                        if (ship->useEnergy(extra_charge * ship->jump_drive_energy_per_km_charge / 1000.0f))
                        {
                            ship->jump_drive_charge += extra_charge;
                            if (ship->jump_drive_charge >= ship->jump_drive_max_distance)
                                ship->jump_drive_charge = ship->jump_drive_max_distance;
                        }
                    }
                }else{
                    ship->jump_drive_charge += (delta / ship->jump_drive_charge_time * ship->jump_drive_max_distance) * f;
                    if (ship->jump_drive_charge < 0.0f)
                        ship->jump_drive_charge = 0.0f;
                }
            }
            ship->current_warp = 0.f;
            if (impulse.request > 1.0f)
                impulse.request = 1.0f;
            if (impulse.request < -1.0f)
                impulse.request = -1.0f;
            if (impulse.actual < impulse.request)
            {
                if (cap_speed > 0)
                    impulse.actual += delta * (impulse.acceleration_forward / cap_speed);
                if (impulse.actual > impulse.request)
                    impulse.actual = impulse.request;
            }else if (impulse.actual > impulse.request)
            {
                if (cap_speed > 0)
                    impulse.actual -= delta * (impulse.acceleration_reverse / cap_speed);
                if (impulse.actual < impulse.request)
                    impulse.actual = impulse.request;
            }
        }

        // Add heat based on warp factor.
        ship->addHeat(SYS_Warp, ship->current_warp * delta * ship->heat_per_warp * ship->getSystemEffectiveness(SYS_Warp));

        // Determine forward direction and velocity.
        auto forward = vec2FromAngle(ship->getRotation());
        physics.setVelocity(forward * (impulse.actual * cap_speed * ship->getSystemEffectiveness(SYS_Impulse) + ship->current_warp * ship->warp_speed_per_warp_level * ship->getSystemEffectiveness(SYS_Warp)));
    }
}
