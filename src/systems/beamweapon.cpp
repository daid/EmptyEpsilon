#include "beamweapon.h"
#include "multiplayer_server.h"
#include "components/scanning.h"
#include "components/beamweapon.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/reactor.h"
#include "components/warpdrive.h"
#include "components/target.h"
#include "components/shields.h"
#include "components/faction.h"
#include "components/coolant.h"
#include "components/sfx.h"
#include "ecs/query.h"
#include "main.h"
#include "textureManager.h"
#include "glObjects.h"
#include "shaderRegistry.h"
#include "tween.h"
#include "random.h"
#include "playerInfo.h"

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <graphics/opengl.h>


void BeamWeaponSystem::update(float delta)
{
    if (!game_server) return;
    if (delta <= 0.0f) return;

    for(auto [entity, beamsys, target, transform, reactor, docking_port] : sp::ecs::Query<BeamWeaponSys, Target, sp::Transform, sp::ecs::optional<Reactor>, sp::ecs::optional<DockingPort>>()) {
        auto warp = entity.getComponent<WarpDrive>();

        for(auto& mount : beamsys.mounts) {
            if (mount.cooldown > 0.0f)
                mount.cooldown -= delta * beamsys.getSystemEffectiveness();
            if (!target.entity) continue;

            // Check on beam weapons only if we are on the server, have a target, and
            // not paused, and if the beams are cooled down or have a turret arc.
            if (mount.range > 0.0f && Faction::getRelation(entity, target.entity) == FactionRelation::Enemy && delta > 0.0f && (!warp || warp->current == 0.0f) && (!docking_port || docking_port->state == DockingPort::State::NotDocking))
            {
                if (auto target_transform = target.entity.getComponent<sp::Transform>()) {
                    // Get the angle to the target.
                    auto diff = target_transform->getPosition() - (transform.getPosition() + rotateVec2(glm::vec2(mount.position.x, mount.position.y), transform.getRotation()));
                    float distance = glm::length(diff);
                    if (auto physics = target.entity.getComponent<sp::Physics>())
                        distance -= physics->getSize().x;

                    // We also only care if the target is within no more than its
                    // range * 1.3, which is when we want to start rotating the turret.
                    // TODO: Add a manual aim override similar to weapon tubes.
                    if (distance < mount.range * 1.3f)
                    {
                        float angle = vec2ToAngle(diff);
                        float angle_diff = angleDifference(mount.direction + transform.getRotation(), angle);

                        if (mount.turret_arc > 0)
                        {
                            // Get the target's angle relative to the turret's direction.
                            float turret_angle_diff = angleDifference(mount.turret_direction + transform.getRotation(), angle);

                            // If the turret can rotate ...
                            if (mount.turret_rotation_rate > 0)
                            {
                                // ... and if the target is within the turret's arc ...
                                if (fabsf(turret_angle_diff) < mount.turret_arc / 2.0f)
                                {
                                    // ... rotate the turret's beam toward the target.
                                    if (fabsf(angle_diff) > 0)
                                    {
                                        mount.direction += (angle_diff / fabsf(angle_diff)) * std::min(mount.turret_rotation_rate * beamsys.getSystemEffectiveness(), fabsf(angle_diff));
                                    }
                                // If the target is outside of the turret's arc ...
                                } else {
                                    // ... rotate the turret's beam toward the turret's
                                    // direction to reset it.
                                    float reset_angle_diff = angleDifference(mount.direction, mount.turret_direction);

                                    if (fabsf(reset_angle_diff) > 0)
                                    {
                                        mount.direction += (reset_angle_diff / fabsf(reset_angle_diff)) * std::min(mount.turret_rotation_rate * beamsys.getSystemEffectiveness(), fabsf(reset_angle_diff));
                                    }
                                }
                            }
                        }

                        // If the target is in the beam's arc and range, the beam has cooled
                        // down, and the beam can consume enough energy to fire ...
                        if (distance < mount.range && mount.cooldown <= 0.0f && fabsf(angle_diff) < mount.arc / 2.0f && (!reactor || reactor->useEnergy(mount.energy_per_beam_fire)))
                        {
                            // ... add heat to the beam and zap the target.
                            if (entity.hasComponent<Coolant>())
                                beamsys.addHeat(mount.heat_per_beam_fire);

                            //When we fire a beam, and we hit an enemy, check if we are not scanned yet, if we are not, and we hit something that we know is an enemy or friendly,
                            //  we now know if this ship is an enemy or friend.
                            Faction::didAnOffensiveAction(entity);

                            mount.cooldown = mount.cycle_time; // Reset time of weapon

                            auto hit_location = target_transform->getPosition();
                            auto r = 100.0f;
                            if (auto physics = target.entity.getComponent<sp::Physics>()) {
                                hit_location -= glm::normalize(target_transform->getPosition() - transform.getPosition()) * physics->getSize().x;
                                r = physics->getSize().x;
                            }

                            auto e = sp::ecs::Entity::create();
                            e.addComponent<sp::Transform>(transform);
                            auto& be = e.addComponent<BeamEffect>();
                            be.source = entity;
                            be.target = target.entity;
                            be.source_offset = mount.position;
                            be.target_location = hit_location;
                            be.beam_texture = mount.texture;
                            auto& sfx = e.addComponent<Sfx>();
                            sfx.sound = "sfx/laser_fire.wav";
                            auto beam_fire_sound_power = (mount.damage / 6.0f);
                            sfx.volume = 50.0f + (beam_fire_sound_power * 75.0f);
                            sfx.pitch = (1.0f / beam_fire_sound_power) + random(-0.1f, 0.1f);
                            {
                                auto local_hit_location = hit_location - target_transform->getPosition();
                                be.target_offset = glm::vec3(local_hit_location.x + random(-r/2.0f, r/2.0f), local_hit_location.y + random(-r/2.0f, r/2.0f), random(-r/4.0f, r/4.0f));

                                auto shield = target.entity.getComponent<Shields>();
                                if (shield && shield->active)
                                    be.target_offset = glm::normalize(be.target_offset) * r;
                                else
                                    be.target_offset = glm::normalize(be.target_offset) * random(0, r / 2.0f);
                                be.hit_normal = glm::normalize(be.target_offset);
                            }

                            DamageInfo info(entity, mount.damage_type, hit_location);
                            info.frequency = beamsys.frequency;
                            info.system_target = beamsys.system_target;
                            DamageSystem::applyDamage(target.entity, mount.damage, info);
                        }
                    }
                }
            // If the beam is turreted and can move, but doesn't have a target, reset it
            // if necessary.
            } else if (mount.range > 0.0f && mount.turret_arc > 0.0f && mount.direction != mount.turret_direction && mount.turret_rotation_rate > 0) {
                float reset_angle_diff = angleDifference(mount.direction, mount.turret_direction);

                if (fabsf(reset_angle_diff) > 0)
                {
                    mount.direction += (reset_angle_diff / fabsf(reset_angle_diff)) * std::min(mount.turret_rotation_rate * beamsys.getSystemEffectiveness(), fabsf(reset_angle_diff));
                }
            }
        }
    }

    for(auto [entity, be, transform] : sp::ecs::Query<BeamEffect, sp::Transform>()) {
        if (be.source) {
            if (auto st = be.source.getComponent<sp::Transform>())
                transform.setPosition(st->getPosition() + rotateVec2(glm::vec2(be.source_offset.x, be.source_offset.y), st->getRotation()));
        }
        if (be.target) {
            if (auto tt = be.target.getComponent<sp::Transform>())
                be.target_location = tt->getPosition() + glm::vec2(be.target_offset.x, be.target_offset.y);
        }

        be.lifetime -= delta * be.fade_speed;
        if (be.lifetime < 0 && game_server)
            entity.destroy();
    }
}

void BeamWeaponSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, BeamEffect& be)
{
    glm::vec3 startPoint(transform.getPosition().x, transform.getPosition().y, be.source_offset.z);
    glm::vec3 endPoint(be.target_location.x, be.target_location.y, be.target_offset.z);
    glm::vec3 eyeNormal = glm::normalize(glm::cross(camera_position - startPoint, endPoint - startPoint));

    textureManager.getTexture(be.beam_texture)->bind();

    ShaderRegistry::ScopedShader beamShader(ShaderRegistry::Shaders::Basic);

    auto model_matrix = glm::identity<glm::mat4>();

    glUniform4f(beamShader.get().uniform(ShaderRegistry::Uniforms::Color), be.lifetime, be.lifetime, be.lifetime, 1.f);
    glUniformMatrix4fv(beamShader.get().uniform(ShaderRegistry::Uniforms::Model), 1, false, glm::value_ptr(model_matrix));
    
    gl::ScopedVertexAttribArray positions(beamShader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(beamShader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    struct VertexAndTexCoords
    {
        glm::vec3 vertex;
        glm::vec2 texcoords;
    };

    std::array<VertexAndTexCoords, 4> quad;
    // Beam
    {
        glm::vec3 v0 = startPoint + eyeNormal * 4.0f;
        glm::vec3 v1 = endPoint + eyeNormal * 4.0f;
        glm::vec3 v2 = endPoint - eyeNormal * 4.0f;
        glm::vec3 v3 = startPoint - eyeNormal * 4.0f;
        quad[0].vertex = v0;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v1;
        quad[1].texcoords = { 0.f, 1.f };
        quad[2].vertex = v2;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v3;
        quad[3].texcoords = { 1.f, 0.f };

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        // Draw the beam
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));

    }

    // Fire ring
    if (be.fire_ring)
    {
        glm::vec3 side = glm::cross(be.hit_normal, glm::vec3(0, 0, 1));
        glm::vec3 up = glm::cross(side, be.hit_normal);

        glm::vec3 v0(be.target_location.x, be.target_location.y, be.target_offset.z);

        float ring_size = Tween<float>::easeOutCubic(be.lifetime, 1.0, 0.0, 10.0f, 80.0f);
        auto v1 = v0 + side * ring_size + up * ring_size;
        auto v2 = v0 - side * ring_size + up * ring_size;
        auto v3 = v0 - side * ring_size - up * ring_size;
        auto v4 = v0 + side * ring_size - up * ring_size;

        quad[0].vertex = v1;
        quad[0].texcoords = { 0.f, 0.f };
        quad[1].vertex = v2;
        quad[1].texcoords = { 1.f, 0.f };
        quad[2].vertex = v3;
        quad[2].texcoords = { 1.f, 1.f };
        quad[3].vertex = v4;
        quad[3].texcoords = { 0.f, 1.f };

        textureManager.getTexture("texture/fire_ring.png")->bind();
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));

        // Draw two quads with opposite winding order for double-sided rendering
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0, 0, 3, 2, 2, 1, 0 };
        glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

static void drawArc(sp::RenderTarget& renderer, glm::vec2 arc_center, float angle0, float arc_angle, float arc_radius, glm::u8vec4 color)
{
    // Initialize variables from the beam's data.
    float beam_arc = arc_angle;
    float beam_range = arc_radius;

    // Set the beam's origin on radar to its relative position on the mesh.
    float outline_thickness = std::min(20.0f, beam_range * 0.2f);
    float beam_arc_curve_length = beam_range * beam_arc / 180.0f * glm::pi<float>();
    outline_thickness = std::min(outline_thickness, beam_arc_curve_length * 0.25f);

    size_t curve_point_count = 0;
    if (outline_thickness > 0.f)
        curve_point_count = static_cast<size_t>(beam_arc_curve_length / (outline_thickness * 0.9f));

    struct ArcPoint {
        glm::vec2 point;
        glm::vec2 normal; // Direction towards the center.
    };

    //Arc points
    std::vector<ArcPoint> arc_points;
    arc_points.reserve(curve_point_count + 1);
    
    for (size_t i = 0; i < curve_point_count; i++)
    {
        auto angle = vec2FromAngle(angle0 + i * beam_arc / curve_point_count) * beam_range;
        arc_points.emplace_back(ArcPoint{ arc_center + angle, glm::normalize(angle) });
    }
    {
        auto angle = vec2FromAngle(angle0 + beam_arc) * beam_range;
        arc_points.emplace_back(ArcPoint{ arc_center + angle, glm::normalize(angle) });
    }

    for (size_t n = 0; n < arc_points.size() - 1; n++)
    {
        const auto& p0 = arc_points[n].point;
        const auto& p1 = arc_points[n + 1].point;
        const auto& n0 = arc_points[n].normal;
        const auto& n1 = arc_points[n + 1].normal;
        renderer.drawTexturedQuad("gradient.png",
            p0, p0 - n0 * outline_thickness,
            p1 - n1 * outline_thickness, p1,
            { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
            color);
    }

    if (beam_arc < 360.f)
    {
        // Arc bounds.
        // We use the left- and right-most edges as lines, going inwards, parallel to the center.
        const auto left_edge = vec2FromAngle(angle0) * beam_range;
        const auto right_edge = vec2FromAngle(angle0 + beam_arc) * beam_range;
    
        // Compute the half point, always going clockwise from the left edge.
        // This makes sure the algorithm never takes the short road.
        auto halfway_angle = vec2FromAngle(angle0 + beam_arc / 2.f) * beam_range;
        auto middle = glm::normalize(halfway_angle);

        // Edge vectors.
        const auto left_edge_vector = glm::normalize(left_edge);
        const auto right_edge_vector = glm::normalize(right_edge);

        // Edge normals, inwards.
        auto left_edge_normal = glm::vec2{ left_edge_vector.y, -left_edge_vector.x };
        const auto right_edge_normal = glm::vec2{ -right_edge_vector.y, right_edge_vector.x };

        // Initial offset, follow along the edges' normals, inwards.
        auto left_inner_offset = -left_edge_normal * outline_thickness;
        auto right_inner_offset = -right_edge_normal * outline_thickness;

        if (beam_arc < 180.f)
        {
            // The thickness being perpendicular from the edges,
            // the inner lines just crosses path on the height,
            // so just use that point.
            left_inner_offset = middle * outline_thickness / sinf(glm::radians(beam_arc / 2.f));
            right_inner_offset = left_inner_offset;
        }
        else
        {
            // Make it shrink nicely as it grows up to 360 deg.
            // For that, we use the edge's normal against the height which will change from 0 to 90deg.
            // Also flip the direction so our points stay inside the beam.
            auto thickness_scale = -glm::dot(middle, right_edge_normal);
            left_inner_offset *= thickness_scale;
            right_inner_offset *= thickness_scale;
        }

        renderer.drawTexturedQuad("gradient.png",
            arc_center, arc_center + left_inner_offset,
            arc_center + left_edge - left_edge_normal * outline_thickness, arc_center + left_edge,
            { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
            color);

        renderer.drawTexturedQuad("gradient.png",
            arc_center, arc_center + right_inner_offset,
            arc_center + right_edge - right_edge_normal * outline_thickness, arc_center + right_edge,
            { 0.f, 0.5f }, { 1.f, 0.5f }, { 1.f, 0.5f }, { 0.f, 0.5f },
            color);
    }
};

void BeamWeaponSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity entity, glm::vec2 screen_position, float scale, float rotation, BeamWeaponSys& beamsystem)
{
    if (entity != my_spaceship) {
        auto scanstate = entity.getComponent<ScanState>();
        if (scanstate && my_spaceship && scanstate->getStateFor(my_spaceship) != ScanState::State::FullScan)
            return;
    }

    // For each beam ...
    for(auto& mount : beamsystem.mounts) {
        // Draw beam arcs only if the beam has a range. A beam with range 0
        // effectively doesn't exist; exit if that's the case.
        if (mount.range == 0.0f) continue;

        // If the beam is cooling down, flash and fade the arc color.
        glm::u8vec4 color = Tween<glm::u8vec4>::linear(std::max(0.0f, mount.cooldown), 0, mount.cycle_time, mount.arc_color, mount.arc_color_fire);

        
        // Initialize variables from the beam's data.
        float beam_direction = mount.direction;
        float beam_arc = mount.arc;
        float beam_range = mount.range;

        // Set the beam's origin on radar to its relative position on the mesh.
        auto beam_offset = rotateVec2(glm::vec2(mount.position.x, mount.position.y) * scale, rotation);
        auto arc_center = beam_offset + screen_position;

        drawArc(renderer, arc_center, rotation + (beam_direction - beam_arc / 2.0f), beam_arc, beam_range * scale, color);
    

        // If the beam is turreted, draw the turret's arc. Otherwise, exit.
        if (mount.turret_arc == 0.0f)
            continue;

        // Initialize variables from the turret data.
        float turret_arc = mount.turret_arc;
        float turret_direction = mount.turret_direction;

        // Draw the turret's bounds, at half the transparency of the beam's.
        // TODO: Make this color configurable.
        color.a /= 4;

        drawArc(renderer, arc_center, rotation + (turret_direction - turret_arc / 2.0f), turret_arc, beam_range * scale, color);
    }
}