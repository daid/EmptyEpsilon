#include "ecs.h"
#include "script/components.h"
#include <engine.h>

#include "ecs/multiplayer.h"
#include "multiplayer/collision.h"

#include "systems/ai.h"
#include "systems/docking.h"
#include "systems/comms.h"
#include "systems/impulse.h"
#include "systems/warpsystem.h"
#include "systems/jumpsystem.h"
#include "systems/beamweapon.h"
#include "systems/shieldsystem.h"
#include "systems/shipsystemssystem.h"
#include "systems/coolantsystem.h"
#include "systems/missilesystem.h"
#include "systems/maneuvering.h"
#include "systems/energysystem.h"
#include "systems/selfdestruct.h"
#include "systems/basicmovement.h"
#include "systems/gravity.h"
#include "systems/internalcrew.h"
#include "systems/pathfinding.h"
#include "systems/rendering.h"
#include "systems/planet.h"
#include "systems/scanning.h"
#include "systems/radar.h"


void initSystemsAndComponents()
{
    //BeamWeaponSys
    //BeamEffect
    //CommsReceiver (client needs to know this exists to be able to initiate comms)
    //CommsTransmitter
    //Coolant
    //CustomShipFunctions
    //Database
    //DockingBay
    //DockingPort
    //Faction
    //FactionInfo
    //Gravity
    //HackingDevice
    //Hull
    //ImpulseEngine
    //InternalRooms
    //InternalCrew
    //JumpDrive
    //ManeuveringThrusters
    //CombatManeuveringThrusters
    //MissileFlight
    //MissileHoming
    //ConstantParticleEmitter
    //MissileTubes
    //MoveTo
    //CallSign
    //TypeName
    //Orbit
    //PlayerControl
    //ScanProbeLauncher
    sp::ecs::MultiplayerReplication::registerComponentReplication<sp::ecs::ComponentReplication<RadarTrace>>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<sp::ecs::ComponentReplication<RawRadarSignatureInfo>>();
    //LongRangeRadar
    //ShareShortRangeRadar
    //AllowRadarLink
    //RadarBlock
    //NeverRadarBlocked
    //Reactor
    //MeshRenderComponent
    //EngineEmitter
    //NebulaRenderer
    //ExplosionEffect
    //PlanetRender
    //ScanState
    //ScienceDescription
    //ScienceScanner
    //SelfDestruct
    //Sfx
    //Shields
    //ShipLog
    //Spin
    //Target
    //WarpDrive
    //WarpJammer
    //Zone
    sp::ecs::MultiplayerReplication::registerComponentReplication<sp::multiplayer::TransformReplication>();
    //sp::Physics

    engine->registerSystem<AISystem>();
    engine->registerSystem<DamageSystem>();
    engine->registerSystem<EnergySystem>();
    engine->registerSystem<DockingSystem>();
    engine->registerSystem<CommsSystem>();
    engine->registerSystem<ImpulseSystem>();
    engine->registerSystem<ManeuveringSystem>();
    engine->registerSystem<WarpSystem>();
    engine->registerSystem<JumpSystem>();
    engine->registerSystem<BeamWeaponSystem>();
    engine->registerSystem<MissileSystem>();
    engine->registerSystem<ShieldSystem>();
    engine->registerSystem<CoolantSystem>();
    engine->registerSystem<ShipSystemsSystem>();
    engine->registerSystem<SelfDestructSystem>();
    engine->registerSystem<BasicMovementSystem>();
    engine->registerSystem<GravitySystem>();
    engine->registerSystem<InternalCrewSystem>();
    engine->registerSystem<PathFindingSystem>();
    engine->registerSystem<NebulaRenderSystem>();
    engine->registerSystem<ExplosionRenderSystem>();
    engine->registerSystem<PlanetRenderSystem>();
    engine->registerSystem<PlanetTransparentRenderSystem>();
    engine->registerSystem<MeshRenderSystem>();
    engine->registerSystem<ScanningSystem>();
    engine->registerSystem<BasicRadarRendering>();
    initComponentScriptBindings();
}
