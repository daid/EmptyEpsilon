#include "ecs.h"
#include "script/components.h"
#include <engine.h>

#include "ecs/multiplayer.h"
#include "multiplayer/collision.h"
#include "multiplayer/faction.h"
#include "multiplayer/radar.h"
#include "multiplayer/comms.h"
#include "multiplayer/player.h"
#include "multiplayer/name.h"
#include "multiplayer/impulse.h"
#include "multiplayer/warp.h"
#include "multiplayer/docking.h"
#include "multiplayer/hull.h"
#include "multiplayer/coolant.h"
#include "multiplayer/database.h"

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
    sp::ecs::MultiplayerReplication::registerComponentReplication<CommsReceiverReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CommsTransmitterReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CoolantReplication>();
    //CustomShipFunctions
    sp::ecs::MultiplayerReplication::registerComponentReplication<DatabaseReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<DockingBayReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<DockingPortReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<FactionReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<FactionInfoReplication>();
    //Gravity
    //HackingDevice
    sp::ecs::MultiplayerReplication::registerComponentReplication<HullReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ImpulseEngineReplication>();
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
    sp::ecs::MultiplayerReplication::registerComponentReplication<CallSignReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<TypeNameReplication>();
    //Orbit
    sp::ecs::MultiplayerReplication::registerComponentReplication<PlayerControlReplication>();
    //ScanProbeLauncher
    sp::ecs::MultiplayerReplication::registerComponentReplication<RadarTraceReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<RawRadarSignatureInfoReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<LongRangeRadarReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ShareShortRangeRadarReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<AllowRadarLinkReplication>();
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
    sp::ecs::MultiplayerReplication::registerComponentReplication<WarpDriveReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<WarpJammerReplication>();
    //Zone
    sp::ecs::MultiplayerReplication::registerComponentReplication<sp::multiplayer::TransformReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<sp::multiplayer::PhysicsReplication>();

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
