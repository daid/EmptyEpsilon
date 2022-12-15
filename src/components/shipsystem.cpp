#include "shipsystem.h"
#include "gameGlobalInfo.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/shields.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"

// TODO
static std::array<float, ShipSystem::COUNT> default_system_power_factors{
    /*ShipSystem::Type::Reactor*/     -25.f,
    /*ShipSystem::Type::BeamWeapons*/   3.f,
    /*ShipSystem::Type::MissileSystem*/ 1.f,
    /*ShipSystem::Type::Maneuver*/      2.f,
    /*ShipSystem::Type::Impulse*/       4.f,
    /*ShipSystem::Type::Warp*/          5.f,
    /*ShipSystem::Type::JumpDrive*/     5.f,
    /*ShipSystem::Type::FrontShield*/   5.f,
    /*ShipSystem::Type::RearShield*/    5.f,
};


// Overheat subsystem damage rate
constexpr static float damage_per_second_on_overheat = 0.08f;


float ShipSystem::getSystemEffectiveness()
{
    float power = power_level;

    // Substract the hacking from the power, making double hacked systems run at 25% efficiency.
    power = std::max(0.0f, power - hacked_level * 0.75f);

    // Degrade all systems except the reactor once energy level drops below 10.
    /* TODO
    if (system != SYS_Reactor)
    {
        auto reactor = entity.getComponent<Reactor>();
        if (reactor) {
            if (reactor->energy < 10.0f && reactor->energy > 0.0f && power > 0.0f)
                power = std::min(power * reactor->energy / 10.0f, power);
            else if (reactor->energy <= 0.0f || power <= 0.0f)
                power = 0.0f;
        }
    }*/

    // Degrade damaged systems.
    if (gameGlobalInfo && gameGlobalInfo->use_system_damage)
        return std::max(0.0f, power * health);

    // If a system cannot be damaged, excessive heat degrades it.
    return std::max(0.0f, power * (1.0f - heat_level));
}

void ShipSystem::addHeat(float amount)
{
    heat_level += amount;

    if (heat_level > 1.0f)
    {
        float overheat = heat_level - 1.0f;
        heat_level = 1.0f;

        if (gameGlobalInfo->use_system_damage)
        {
            // Heat damage is specified as damage per second while overheating.
            // Calculate the amount of overheat back to a time, and use that to
            // calculate the actual damage taken.
            health -= overheat / heat_add_rate_per_second * damage_per_second_on_overheat;

            if (health < -1.0f)
                health = -1.0f;
        }
    }

    if (heat_level < 0.0f)
        heat_level = 0.0f;
}

ShipSystem* ShipSystem::get(sp::ecs::Entity entity, Type type)
{
    switch(type)
    {
    case Type::None:
    case Type::COUNT:
        return nullptr;
    case Type::Reactor:
        return entity.getComponent<Reactor>();
    case Type::BeamWeapons:
        return entity.getComponent<BeamWeaponSys>();
    case Type::MissileSystem:
        return entity.getComponent<MissileTubes>();
    case Type::Maneuver:
        return entity.getComponent<ManeuveringThrusters>();
    case Type::Impulse:
        return entity.getComponent<ImpulseEngine>();
    case Type::Warp:
        return entity.getComponent<WarpDrive>();
    case Type::JumpDrive:
        return entity.getComponent<JumpDrive>();
    case Type::FrontShield:
        {
            auto shields = entity.getComponent<Shields>();
            if (shields)
                return &shields->front_system;
            return nullptr;
        }
    case Type::RearShield:
        {
            auto shields = entity.getComponent<Shields>();
            if (shields && shields->count > 1)
                return &shields->rear_system;
            return nullptr;
        }
    }
    return nullptr;
}