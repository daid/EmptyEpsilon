#include "systems/missilesystem.h"

#include "components/collision.h"
#include "components/missiletubes.h"
#include "components/missile.h"
#include "components/lifetime.h"
#include "components/hull.h"
#include "components/radar.h"
#include "components/docking.h"
#include "components/warpdrive.h"
#include "components/sfx.h"
#include "components/rendering.h"
#include "components/faction.h"
#include "components/avoidobject.h"
#include "ecs/query.h"
#include "multiplayer_server.h"
#include "particleEffect.h"
#include "random.h"


MissileSystem::MissileSystem()
{
    sp::CollisionSystem::addHandler(this);
}

void MissileSystem::update(float delta)
{
    for(auto [entity, tubes] : sp::ecs::Query<MissileTubes>())
    {
        for(auto& tube : tubes.mounts)
        {
            if (tube.delay > 0.0f)
            {
                tube.delay -= delta * tubes.getSystemEffectiveness();
            }else{
                switch(tube.state)
                {
                case MissileTubes::MountPoint::State::Loading:
                    tube.state = MissileTubes::MountPoint::State::Loaded;
                    break;
                case MissileTubes::MountPoint::State::Unloading:
                    tube.state = MissileTubes::MountPoint::State::Empty;
                    if (tubes.storage[tube.type_loaded] < tubes.storage_max[tube.type_loaded])
                        tubes.storage[tube.type_loaded]++;
                    tube.type_loaded = MW_None;
                    break;
                case MissileTubes::MountPoint::State::Firing:
                    if (game_server)
                    {
                        spawnProjectile(entity, tube, 0, {});

                        tube.fire_count -= 1;
                        if (tube.fire_count > 0)
                        {
                            tube.delay = 1.5;
                        }
                        else
                        {
                            tube.state = MissileTubes::MountPoint::State::Empty;
                            tube.type_loaded = MW_None;
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
    }

    for(auto [entity, flight, transform, physics] : sp::ecs::Query<MissileFlight, sp::Transform, sp::Physics>()) {
        physics.setVelocity(vec2FromAngle(transform.getRotation()) * flight.speed);
        if (flight.timeout > 0.0f) {
            flight.timeout -= delta;
            if (flight.timeout <= 0.0f && game_server) {
                entity.removeComponent<MissileFlight>();
                physics.setVelocity({0.0f, 0.0f});
            }
        }
    }

    for(auto [entity, homing, transform, physics] : sp::ecs::Query<MissileHoming, sp::Transform, sp::Physics>()) {
        if (auto tt = homing.target.getComponent<sp::Transform>()) {
            float r = homing.range + 10.0f;
            if (glm::length2(tt->getPosition() - transform.getPosition()) < r*r)
                homing.target_angle = vec2ToAngle(tt->getPosition() - transform.getPosition());
        }
        float angle_diff = angleDifference(transform.getRotation(), homing.target_angle);

        if (angle_diff > 1.0f)
            physics.setAngularVelocity(homing.turn_rate);
        else if (angle_diff < -1.0f)
            physics.setAngularVelocity(homing.turn_rate * -1.0f);
        else
            physics.setAngularVelocity(angle_diff * homing.turn_rate);
    }

    // TODO: Not really part of missile
    for(auto [entity, emitter, transform] : sp::ecs::Query<ConstantParticleEmitter, sp::Transform>()) {
        emitter.delay -= delta;
        if (emitter.delay <= 0.0f) {
            emitter.delay = emitter.interval;
            auto pos = glm::vec3(transform.getPosition().x, transform.getPosition().y, 0);
            ParticleEngine::spawn(pos, pos + glm::vec3(random(-emitter.travel_random_range, emitter.travel_random_range), random(-emitter.travel_random_range, emitter.travel_random_range), random(-emitter.travel_random_range, emitter.travel_random_range)), emitter.start_color, emitter.end_color, emitter.start_size, emitter.end_size, emitter.life_time);
        }
    }

    if (game_server) {
        for(auto [entity, deot, transform] : sp::ecs::Query<DelayedExplodeOnTouch, sp::Transform>()) {
            if (deot.trigger_holdoff_delay > 0.0f) deot.trigger_holdoff_delay -= delta;
            if (!deot.triggered) continue;
            deot.delay -= delta;
            if (deot.delay >= 0.0f) continue;

            explode(entity, {}, deot);
        }
    }

    if (game_server) {
        // TODO: Not really part of missile
        for(auto [entity, lifetime] : sp::ecs::Query<LifeTime>()) {
            lifetime.lifetime -= delta;
            if (lifetime.lifetime <= 0.0f) {
                if (entity.hasComponent<ExplodeOnTimeout>()) {
                    if (auto eot = entity.getComponent<ExplodeOnTouch>()) {
                        explode(entity, {}, *eot);
                    }
                }
                entity.destroy();
            }
        }
    }
}

void MissileSystem::collision(sp::ecs::Entity a, sp::ecs::Entity b, float force)
{
    if (!game_server) return;
    auto deot = a.getComponent<DelayedExplodeOnTouch>();
    if (deot && deot->trigger_holdoff_delay <= 0.0f) {
        auto hull = b.getComponent<Hull>();
        if (!hull) return;
        deot->triggered = true;
    }
    auto eot = a.getComponent<ExplodeOnTouch>();
    if (!eot) return;
    if (eot->owner == b) return;
    auto hull = b.getComponent<Hull>();
    if (!hull) return;

    explode(a, b, *eot);
}

void MissileSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, DelayedExplodeOnTouch& component)
{
    auto physics = e.getComponent<sp::Physics>();
    if (!physics) return;
    auto r = physics->getSize().x;
    renderer.drawCircleOutline(screen_position, r * scale, 3.0, component.triggered ? glm::u8vec4(255, 0, 0, 128) : glm::u8vec4(255, 255, 255, 128));
}

void MissileSystem::explode(sp::ecs::Entity source, sp::ecs::Entity target, ExplodeOnTouch& eot)
{
    auto transform = source.getComponent<sp::Transform>();
    if (!transform) return;
    DamageInfo info(eot.owner, eot.damage_type, transform->getPosition());
    if (eot.blast_range > 100.0f || !target) {
        DamageSystem::damageArea(transform->getPosition(), eot.blast_range, eot.damage_at_edge, eot.damage_at_center, info, eot.blast_range / 2);
    } else {
        DamageSystem::applyDamage(target, eot.damage_at_center, info);
    }

    auto e = sp::ecs::Entity::create();
    e.addComponent<sp::Transform>(*transform);
    auto& ee = e.addComponent<ExplosionEffect>();
    ee.size = eot.blast_range;
    ee.radar = true;
    if (!eot.explosion_sfx.empty()) {
        e.addComponent<Sfx>().sound = eot.explosion_sfx;
    }
    if (eot.damage_type == DamageType::EMP) {
        ee.electrical = true;
    }
    source.destroy();
}

void MissileSystem::startLoad(sp::ecs::Entity source, MissileTubes::MountPoint& tube, EMissileWeapons type)
{
    if (!tube.canLoad(type))
        return;
    if (tube.state != MissileTubes::MountPoint::State::Empty)
        return;
    auto tubes = source.getComponent<MissileTubes>();
    if (!tubes) return;
    if (tubes->storage[type] <= 0)
        return;

    tube.state = MissileTubes::MountPoint::State::Loading;
    tube.delay = tube.load_time;
    tube.type_loaded = type;
    tubes->storage[type]--;
}

void MissileSystem::startUnload(sp::ecs::Entity source, MissileTubes::MountPoint& tube)
{
    if (tube.state == MissileTubes::MountPoint::State::Loaded)
    {
        tube.state = MissileTubes::MountPoint::State::Unloading;
        tube.delay = tube.load_time;
    }
}

void MissileSystem::fire(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target)
{
    Faction::didAnOffensiveAction(source);

    auto docking_port = source.getComponent<DockingPort>();
    if (docking_port && docking_port->state != DockingPort::State::NotDocking) return;

    auto warp = source.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f) return;
    if (tube.state != MissileTubes::MountPoint::State::Loaded) return;

    if (tube.type_loaded == MW_HVLI)
    {
        tube.fire_count = 5;
        tube.state = MissileTubes::MountPoint::State::Firing;
        tube.delay = 0.0;
    }else{
        spawnProjectile(source, tube, target_angle, target);
        tube.state = MissileTubes::MountPoint::State::Empty;
        tube.type_loaded = MW_None;
    }
}

void MissileSystem::spawnProjectile(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target)
{
    auto source_transform = source.getComponent<sp::Transform>();
    if (!source_transform) return;
    auto fireLocation = source_transform->getPosition() + rotateVec2(glm::vec2(tube.position), source_transform->getRotation());
    auto category_modifier = MissileWeaponData::convertSizeToCategoryModifier(tube.size);
    auto& mwd = MissileWeaponData::getDataFor(tube.type_loaded);

    sp::ecs::Entity missile;
    switch(tube.type_loaded)
    {
    case MW_Homing:
        {
            missile = sp::ecs::Entity::create();
            auto& mc = missile.addComponent<ExplodeOnTouch>();
            mc.owner = source;
            mc.damage_at_center = 35 * category_modifier;
            mc.damage_at_edge = 5 * category_modifier;
            mc.blast_range = 30 * category_modifier;
            mc.explosion_sfx = "sfx/explosion.wav";
            missile.addComponent<RawRadarSignatureInfo>(0.0f, 0.1f, 0.2f);
        }
        break;
    case MW_Nuke:
        {
            missile = sp::ecs::Entity::create();
            auto& mc = missile.addComponent<ExplodeOnTouch>();
            mc.owner = source;
            mc.damage_at_center = 160.0f * category_modifier;
            mc.damage_at_edge = 30.0f * category_modifier;
            mc.blast_range = 1000.0f * category_modifier;
            mc.explosion_sfx = "sfx/nuke_explosion.wav";
            missile.addComponent<RawRadarSignatureInfo>(0.0f, 0.7f, 0.1f);
            missile.addComponent<DelayedAvoidObject>(10.0f, 1000.0f);
            missile.addComponent<ExplodeOnTimeout>();
        }
        break;
    case MW_Mine:
        {
            missile = sp::ecs::Entity::create();
            auto& mc = missile.addComponent<DelayedExplodeOnTouch>();
            mc.trigger_holdoff_delay = mwd.lifetime;
            mc.delay = 1.0f;
            mc.owner = source;
            mc.damage_at_center = 160.0f * category_modifier;
            mc.damage_at_edge = 30.0f * category_modifier;
            mc.blast_range = 1000.0f * category_modifier;
            mc.explosion_sfx = "sfx/explosion.wav";
            missile.addComponent<RawRadarSignatureInfo>(0.0f, 0.05f, 0.0f);
        }
        break;
    case MW_HVLI:
        {
            missile = sp::ecs::Entity::create();
            auto& mc = missile.addComponent<ExplodeOnTouch>();
            mc.owner = source;
            mc.damage_at_center = 10.0f * category_modifier;
            mc.damage_at_edge = 10.0f * category_modifier;
            mc.blast_range = 20.0f * category_modifier;
            mc.explosion_sfx = "sfx/explosion.wav";
            missile.addComponent<RawRadarSignatureInfo>(0.1f, 0.0f, 0.0f);
        }
        break;
    case MW_EMP:
        {
            missile = sp::ecs::Entity::create();
            auto& mc = missile.addComponent<ExplodeOnTouch>();
            mc.owner = source;
            mc.damage_at_center = 160.0f * category_modifier;
            mc.damage_at_edge = 30.0f * category_modifier;
            mc.blast_range = 1000.0f * category_modifier;
            mc.damage_type = DamageType::EMP;
            mc.explosion_sfx = "sfx/emp_explosion.wav";
            missile.addComponent<RawRadarSignatureInfo>(0.0f, 1.0f, 0.0f);
            missile.addComponent<ExplodeOnTimeout>();
        }
        break;
    default:
        break;
    }

    if (missile) {
        auto& physics = missile.addComponent<sp::Physics>();
        if (tube.type_loaded == MW_Mine)
            physics.setCircle(sp::Physics::Type::Sensor, 1000.0f * 0.6f);
        else
            physics.setRectangle(sp::Physics::Type::Sensor, {10, 30});

        auto& mf = missile.addComponent<MissileFlight>();
        mf.speed = mwd.speed / category_modifier;
        if (tube.type_loaded == MW_Mine)
            mf.timeout = mwd.lifetime;
        if (mwd.homing_range > 0.0f) {
            auto& mh = missile.addComponent<MissileHoming>();
            mh.range = mwd.homing_range;
            mh.target = target;
            mh.target_angle = target_angle;
            mh.turn_rate = mwd.turnrate / category_modifier;
        }

        if (auto f = source.getComponent<Faction>())
            missile.addComponent<Faction>().entity = f->entity;
        auto& t = missile.addComponent<sp::Transform>();
        t.setPosition(fireLocation);
        t.setRotation(source_transform->getRotation() + tube.direction);
        auto& cpe = missile.addComponent<ConstantParticleEmitter>();
        if (tube.type_loaded == MW_Mine) {
            cpe.travel_random_range = 100.0f;
            cpe.start_color = {1, 1, 1};
            cpe.end_color = {0, 0, 1};
            cpe.interval = 0.4;
            cpe.start_size = 30.0f;
            cpe.end_size = 0.0f;
            cpe.life_time = 10.0f;
        }

        if (tube.type_loaded != MW_Mine)
            missile.addComponent<LifeTime>().lifetime = mwd.lifetime * category_modifier;

        if (tube.type_loaded != MW_Mine) {
            auto& dbad = missile.addComponent<DestroyedByAreaDamage>();
            dbad.damaged_by_flags = (1 << int(DamageType::EMP)) | (1 << int(DamageType::Energy));
        }

        auto& trace = missile.addComponent<RadarTrace>();
        if (tube.type_loaded == MW_Mine)
            trace.icon = "radar/mine.png";
        else
            trace.icon = "radar/missile.png";
        trace.radius = 32.0f;
        trace.max_size = trace.min_size = 32 * (0.25f + 0.25f * category_modifier);
        trace.flags = RadarTrace::Rotate;
        trace.color = mwd.color;
    }
}

static float calculateTurnAngle(glm::vec2 aim_position, float turn_direction, float turn_radius)
{
    float turn_angle;
    const float d = glm::length(aim_position - turn_direction*glm::vec2(0.0f, turn_radius)); // Distance from turn center
    if (d >= turn_radius)
    {
        const float a = glm::atan(aim_position.x, turn_direction*aim_position.y - turn_radius);
        const float b = glm::acos(turn_radius / d);
        turn_angle = float(M_PI) - a - b;
        if (turn_angle < 0.0f)
            turn_angle = turn_angle + 2.0f*float(M_PI);
    }
    else
    {
        turn_angle = 0.0f;
    }
    return turn_angle;
}

float MissileSystem::calculateFiringSolution(sp::ecs::Entity source, const MissileTubes::MountPoint& tube, sp::ecs::Entity target)
{
    if (!target)
        return std::numeric_limits<float>::infinity();
    const MissileWeaponData& missile = MissileWeaponData::getDataFor(tube.type_loaded);
    if (missile.turnrate == 0.0f)  //If the missile cannot turn, we cannot find a firing solution.
        return std::numeric_limits<float>::infinity();
    auto source_transform = source.getComponent<sp::Transform>();
    if (!source_transform)
        return std::numeric_limits<float>::infinity();
    auto target_transform = target.getComponent<sp::Transform>();
    if (!target_transform)
        return std::numeric_limits<float>::infinity();
    auto target_physics = target.getComponent<sp::Physics>();

    const float tube_angle = source_transform->getRotation() + tube.direction; // Degrees
    const float turn_rate = glm::radians(missile.turnrate);
    const float turn_radius = missile.speed / turn_rate;

    // Get target parameters in the tube centered reference frame:
    // X axis pointing in direction of fire
    // Y axis pointing to the right of the tube
    const glm::vec2 target_position = rotateVec2(target_transform->getPosition() - source_transform->getPosition(), -tube_angle);
    glm::vec2 target_velocity = {0, 0};
    if (target_physics)
        target_velocity = rotateVec2(target_physics->getVelocity(), -tube_angle);

    const int MAX_ITER = 10;
    const float tolerance = 0.1f * (target_physics ? target_physics->getSize().x : 300.0f);
    bool converged = false;
    glm::vec2 aim_position = target_position; // Set initial aim point
    float turn_direction; // Left: -1, Right: +1, No turn: 0
    float turn_angle; // In radians. Value of 0 means no turn.
    for (int iterations=0; iterations<MAX_ITER && converged == false; iterations++)
    {
        // Select turn direction and calculate turn angle
        // Turn in the direction of the target on condition that the target
        // is not inside the turning circle of that side. If it is inside
        // the turning circle, turn in the opposite direction.
        const float d_left = glm::length(aim_position + glm::vec2(0.0f, turn_radius)); // Distance from left turn center
        const float d_right = glm::length(aim_position - glm::vec2(0.0f, turn_radius)); // Distance from right turn center
        if (d_left >= turn_radius && (aim_position.y < 0.0f || d_right < turn_radius))
        {
            turn_direction = -1.0f;
            turn_angle = calculateTurnAngle(aim_position, turn_direction, turn_radius);
        }
        else if (d_right >= turn_radius && (aim_position.y >= 0.0f || d_left < turn_radius))
        {
            turn_direction = 1.0f;
            turn_angle = calculateTurnAngle(aim_position, turn_direction, turn_radius);
        }
        else
        {
            turn_direction = 0.0f;
            turn_angle = 0.0f;
        }

        // Calculate missile and target parameters at turn exit
        const float exit_time = turn_angle / turn_rate;
        const glm::vec2 missile_position_exit = turn_radius * glm::vec2(glm::sin(turn_angle), turn_direction * (1.0f - glm::cos(turn_angle)));
        const glm::vec2 missile_velocity = missile.speed * glm::vec2(glm::cos(turn_angle), turn_direction * glm::sin(turn_angle));
        const glm::vec2 target_position_exit = glm::vec2(target_position + target_velocity*exit_time);

        // Calculate nearest approach
        const glm::vec2 relative_position_exit = target_position_exit - missile_position_exit;
        const glm::vec2 relative_velocity = target_velocity - missile_velocity;
        const float relative_speed = glm::length(relative_velocity);
        float nearest_time; // Time after turn exit when nearest approach occurs
        if (relative_speed == 0.0f)
            nearest_time = 0.0f;
        else
            nearest_time = -glm::dot(relative_position_exit, relative_velocity) / relative_speed / relative_speed;
        const float nearest_distance = glm::length(relative_position_exit + relative_velocity*nearest_time);

        // Check if solution has converged or if we must adjust aim
        if (nearest_distance < tolerance && nearest_time >= 0.0f)
            converged = true;
        else
            aim_position = target_position + target_velocity*(exit_time + nearest_time);
    }
    if (!converged || turn_angle >= float(M_PI))
        return std::numeric_limits<float>::infinity();
    return tube_angle + glm::degrees(turn_direction*turn_angle);
}
