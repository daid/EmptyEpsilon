#include "ecs.h"
#include "script/components.h"
#include <engine.h>

#include "ecs/multiplayer.h"
#include "multiplayer/beamweapon.h"
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
#include "multiplayer/maneuveringthrusters.h"
#include "multiplayer/jumpdrive.h"
#include "multiplayer/hacking.h"
#include "multiplayer/customshipfunction.h"
#include "multiplayer/gravity.h"
#include "multiplayer/scanning.h"
#include "multiplayer/missile.h"
#include "multiplayer/missiletubes.h"
#include "multiplayer/internalrooms.h"

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
#include "systems/radarblock.h"


void initSystemsAndComponents()
{
    sp::ecs::MultiplayerReplication::registerComponentReplication<BeamWeaponSysReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<BeamEffectReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CommsReceiverReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CommsTransmitterReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CoolantReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CustomShipFunctionsReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<DatabaseReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<DockingBayReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<DockingPortReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<FactionReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<FactionInfoReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<GravityReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<HackingDeviceReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<HullReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ImpulseEngineReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<InternalRoomsReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<InternalCrewReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<JumpDriveReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ManeuveringThrustersReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<CombatManeuveringThrustersReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<MissileFlightReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<MissileHomingReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ConstantParticleEmitterReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<MissileTubesReplication>();
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
    sp::ecs::MultiplayerReplication::registerComponentReplication<ScanStateReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ScienceDescriptionReplication>();
    sp::ecs::MultiplayerReplication::registerComponentReplication<ScienceScannerReplication>();
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
    engine->registerSystem<RadarBlockSystem>();
    initComponentScriptBindings();
}
