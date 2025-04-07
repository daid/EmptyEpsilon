#include "shipsystem.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/shields.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"


float ShipSystem::getSystemEffectiveness()
{
    float power = power_level;

    // Substract the hacking from the power, making double hacked systems run at 25% efficiency.
    power = std::max(0.0f, power - hacked_level * 0.75f);

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
            if (shields && shields->entries.size() > 1)
                return &shields->rear_system;
            return nullptr;
        }
    }
    return nullptr;
}

string getSystemName(ShipSystem::Type system)
{
    switch(system)
    {
    case ShipSystem::Type::Reactor: return "reactor";
    case ShipSystem::Type::BeamWeapons: return "beamweapons";
    case ShipSystem::Type::MissileSystem: return "missilesystem";
    case ShipSystem::Type::Maneuver: return "maneuvering";
    case ShipSystem::Type::Impulse: return "impulse";
    case ShipSystem::Type::Warp: return "warpdrive";
    case ShipSystem::Type::JumpDrive: return "jumpdrive";
    case ShipSystem::Type::FrontShield: return "frontshield";
    case ShipSystem::Type::RearShield: return "rearshield";
    default:
        return "UNKNOWN";
    }
}

string getLocaleSystemName(ShipSystem::Type system)
{
    switch(system)
    {
    case ShipSystem::Type::Reactor: return tr("system", "Reactor");
    case ShipSystem::Type::BeamWeapons: return tr("system", "Beam Weapons");
    case ShipSystem::Type::MissileSystem: return tr("system", "Missile System");
    case ShipSystem::Type::Maneuver: return tr("system", "Maneuvering");
    case ShipSystem::Type::Impulse: return tr("system", "Impulse Engines");
    case ShipSystem::Type::Warp: return tr("system", "Warp Drive");
    case ShipSystem::Type::JumpDrive: return tr("system", "Jump Drive");
    case ShipSystem::Type::FrontShield: return tr("system", "Front Shield Generator");
    case ShipSystem::Type::RearShield: return tr("system", "Rear Shield Generator");
    default:
        return "UNKNOWN";
    }
}
