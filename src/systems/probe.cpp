#include "systems/probe.h"
#include "random.h"

#include "components/probe.h"
#include "components/radar.h"
#include "components/moveto.h"
#include "components/lifetime.h"
#include "components/rendering.h"
#include "components/name.h"
#include "components/faction.h"
#include "components/hull.h"
#include "components/collision.h"

#include "menus/luaConsole.h"

sp::ecs::Entity ProbeSystem::launch(sp::ecs::Entity ship, glm::vec2 target)
{
    // Return an empty entity early if the ship lacks a probe launcher, probes,
    // or a transform.
    auto probe_launcher = ship.getComponent<ScanProbeLauncher>();
    if (!probe_launcher) return {};
    auto ship_transform = ship.getComponent<sp::Transform>();
    if (!ship_transform || probe_launcher->stock <= 0) return {};

    // Create a probe entity.
    auto probe = sp::ecs::Entity::create();
    probe.addComponent<sp::Transform>(*ship_transform);
    probe.addComponent<CallSign>().callsign = probe.toString().split(":", 1)[0] + "P";
    probe.addComponent<LifeTime>().lifetime = 600.0f; // 600 sec., 10 min.

    // Apply the launching ship's faction, if any.
    if (auto faction = ship.getComponent<Faction>())
        probe.addComponent<Faction>() = *faction;

    // Launch the probe to the target coordintes at 1U/sec.
    auto& move_to = probe.addComponent<MoveTo>();
    move_to.target = target;
    move_to.speed = 1000.0f;

    // Connect the radar link capacity to the launching entity.
    probe.addComponent<AllowRadarLink>().owner = ship;
    // Share short-range radar with allies.
    probe.addComponent<ShareShortRangeRadar>();

    // Decorate the probe on radar.
    auto& trace = probe.addComponent<RadarTrace>();
    trace.icon = "radar/probe.png";
    trace.min_size = 10.0f;
    trace.max_size = 10.0f;
    trace.color = {96, 192, 128, 255};
    trace.flags = RadarTrace::LongRange;

    // TODO: setRadarSignatureInfo(0.0, 0.2, 0.0);

    // Assign a random mesh for 3D views.
    auto model = "SensorBuoy/SensorBuoyMKI.model";
    auto idx = irandom(1, 3);
    if (idx == 2) model = "SensorBuoy/SensorBuoyMKII.model";
    if (idx == 3) model = "SensorBuoy/SensorBuoyMKIII.model";
    auto& mesh_render = probe.addComponent<MeshRenderComponent>();
    mesh_render.mesh.name = model;
    mesh_render.texture.name = "SensorBuoy/SensorBuoyAlbedoAO.png";
    mesh_render.specular_texture.name = "SensorBuoy/SensorBuoyPBRSpecular.png";
    mesh_render.scale = 300.0f;

    // Assign a physics collider.
    auto& physics = probe.addComponent<sp::Physics>();
    physics.setCircle(sp::Physics::Type::Sensor, 15.0f);

    // Fire the on_launch callback if present.
    if (probe_launcher->on_launch)
        LuaConsole::checkResult(probe_launcher->on_launch.call<void>(ship, probe));

    // Decrement the launcher's probe stocks.
    probe_launcher->stock--;

    // Return the probe entity.
    return probe;
}
