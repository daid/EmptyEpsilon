#include "beamweapon.h"
#include "multiplayer_server.h"
#include "components/beamweapon.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/reactor.h"
#include "components/warpdrive.h"
#include "components/target.h"
#include "components/shields.h"
#include "components/faction.h"
#include "components/sfx.h"
#include "ecs/query.h"
#include "main.h"
#include "textureManager.h"
#include "glObjects.h"
#include "shaderRegistry.h"
#include "tween.h"
#include "random.h"

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <graphics/opengl.h>


BeamWeaponSystem::BeamWeaponSystem()
{
    RenderSystem::add3DHandler<BeamEffect>(this, true);
}

void BeamWeaponSystem::update(float delta)
{
    if (!game_server) return;
    if (delta <= 0.0f) return;

    for(auto [entity, beamsys, target, transform, reactor, docking_port] : sp::ecs::Query<BeamWeaponSys, Target, sp::Transform, sp::ecs::optional<Reactor>, sp::ecs::optional<DockingPort>>()) {
        if (!target.entity) continue;
        auto warp = entity.getComponent<WarpDrive>();

        for(auto& mount : beamsys.mounts) {
            if (mount.cooldown > 0.0f)
                mount.cooldown -= delta * beamsys.getSystemEffectiveness();

            // Check on beam weapons only if we are on the server, have a target, and
            // not paused, and if the beams are cooled down or have a turret arc.
            if (mount.range > 0.0f && Faction::getRelation(entity, target.entity) == FactionRelation::Enemy && delta > 0.0f && (!warp || warp->current == 0.0f) && (!docking_port || docking_port->state == DockingPort::State::NotDocking))
            {
                if (auto target_transform = target.entity.getComponent<sp::Transform>()) {
                    // Get the angle to the target.
                    auto diff = target_transform->getPosition() - (transform.getPosition() + rotateVec2(glm::vec2(mount.position.x, mount.position.y), transform.getRotation()));
                    float distance = glm::length(diff);
                    if (auto physics = target.entity.getComponent<sp::Physics>())
                        distance += physics->getSize().x;

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
                            sfx.power = mount.damage / 6.0f;
                            {
                                hit_location -= target_transform->getPosition();
                                be.target_offset = glm::vec3(hit_location.x + random(-r/2.0f, r/2.0f), hit_location.y + random(-r/2.0f, r/2.0f), random(-r/4.0f, r/4.0f));

                                auto shield = target.entity.getComponent<Shields>();
                                if (shield && shield->active)
                                    be.target_offset = glm::normalize(be.target_offset) * r;
                                else
                                    be.target_offset = glm::normalize(be.target_offset) * random(0, r / 2.0f);
                            }

                            DamageInfo info(entity, mount.damage_type, hit_location);
                            info.frequency = beamsys.frequency;
                            info.system_target = beamsys.system_target;
                            DamageSystem::applyDamage(entity, mount.damage, info);
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

        be.lifetime -= delta;
        if (be.lifetime < 0)
            entity.destroy();
    }
}

void BeamWeaponSystem::render3D(sp::ecs::Entity e)
{
    auto be = e.getComponent<BeamEffect>();
    auto transform = e.getComponent<sp::Transform>();
    if (!be || !transform) return;

    glm::vec3 startPoint(transform->getPosition().x, transform->getPosition().y, be->source_offset.z);
    glm::vec3 endPoint(be->target_location.x, be->target_location.y, be->target_offset.z);
    glm::vec3 eyeNormal = glm::normalize(glm::cross(camera_position - startPoint, endPoint - startPoint));

    textureManager.getTexture(be->beam_texture)->bind();

    ShaderRegistry::ScopedShader beamShader(ShaderRegistry::Shaders::Basic);

    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ transform->getPosition().x, transform->getPosition().y, 0.f });
    model_matrix = glm::rotate(model_matrix, glm::radians(transform->getRotation()), glm::vec3{ 0.f, 0.f, 1.f });

    glUniform4f(beamShader.get().uniform(ShaderRegistry::Uniforms::Color), be->lifetime, be->lifetime, be->lifetime, 1.f);
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
    if (be->fire_ring)
    {
        glm::vec3 side = glm::cross(be->hit_normal, glm::vec3(0, 0, 1));
        glm::vec3 up = glm::cross(side, be->hit_normal);

        glm::vec3 v0(be->target_location.x, be->target_location.y, be->target_offset.z);

        float ring_size = Tween<float>::easeOutCubic(be->lifetime, 1.0, 0.0, 10.0f, 80.0f);
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
        std::initializer_list<uint16_t> indices = { 0, 1, 2, 2, 3, 0 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}
