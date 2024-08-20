#pragma once

#include <ecs/entity.h>
#include <ecs/query.h>
#include <ecs/system.h>
#include "components/collision.h"
#include "components/rendering.h"
#include "main.h"
#include <glm/geometric.hpp>

template<typename COMPONENT, bool TRANSPARENT> class Render3DInterface {
public:
    Render3DInterface();
    virtual void render3D(sp::ecs::Entity e, sp::Transform& transform, COMPONENT& component) = 0;
};

class RenderSystem
{
public:
    template<typename COMPONENT, bool TRANSPARENT> static void add3DHandler(Render3DInterface<COMPONENT, TRANSPARENT>* rif) {
        render_handlers.push_back({rif, &RenderSystem::findRenderObjects<COMPONENT, TRANSPARENT>});
    }

    void render3D(float aspect, float camera_fov);
private:
    float depth_cutoff_back;
    float depth_cutoff_front;
    glm::vec2 view_vector;
    struct RenderEntry {
        sp::ecs::Entity entity;
        float depth;
        bool transparent;
        void* rif;
        sp::Transform* transform;
        void* component_ptr;
        void (*call_rif)(void* rif_ptr, sp::ecs::Entity e, sp::Transform& transform, void* component_ptr);
    };
    std::vector<std::vector<RenderEntry>> render_lists;

    template<typename COMPONENT, bool TRANSPARENT> void findRenderObjects(void* rif_ptr) {
        for(auto [entity, t, transform] : sp::ecs::Query<COMPONENT, sp::Transform>())
        {
            float depth = glm::dot(view_vector, transform.getPosition() - glm::vec2(camera_position.x, camera_position.y));
            float radius = 5000.0f;
            if (auto physics = entity.template getComponent<sp::Physics>())
                radius = physics->getSize().x;
            if (depth + radius < depth_cutoff_back)
                continue;
            if (depth - radius > depth_cutoff_front)
                continue;
            if (depth > 0 && radius / depth < 1.0f / 500)
                continue;
            int render_list_index = std::max(0, int((depth + radius) / 25000));
            while(render_list_index >= int(render_lists.size()))
                render_lists.emplace_back();
            render_lists[render_list_index].push_back({entity, depth, TRANSPARENT, rif_ptr, &transform, &t, [](void* rif_ptr, sp::ecs::Entity e, sp::Transform& transform, void* comp_ptr) {
                auto rif = reinterpret_cast<Render3DInterface<COMPONENT, TRANSPARENT>*>(rif_ptr);
                auto comp = reinterpret_cast<COMPONENT*>(comp_ptr);
                rif->render3D(e, transform, *comp);
            }});
        }
    }

    struct RenderHandler {
        void* rif;
        void (RenderSystem::* func)(void* rif);
    };
    static std::vector<RenderHandler> render_handlers;
};

template<typename COMPONENT, bool TRANSPARENT> Render3DInterface<COMPONENT, TRANSPARENT>::Render3DInterface() { RenderSystem::add3DHandler(this); }

// FIX: This is obviously not the right place to define these utility functions
glm::mat4 calculateModelMatrix(glm::vec2 position, float rotation, glm::vec3 mesh_offset, float scale);
ShaderRegistry::ScopedShader lookUpShader(MeshRenderComponent& mrc);
void activateAndBindMeshTextures(MeshRenderComponent& mrc);
void drawMesh(MeshRenderComponent& mrc, ShaderRegistry::ScopedShader& shader);

class MeshRenderSystem : public sp::ecs::System, public Render3DInterface<MeshRenderComponent, false>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, MeshRenderComponent& mrc) override;
};

class NebulaRenderSystem : public sp::ecs::System, public Render3DInterface<NebulaRenderer, true>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, NebulaRenderer& nr) override;
};

class ExplosionRenderSystem : public sp::ecs::System, public Render3DInterface<ExplosionEffect, true>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, ExplosionEffect& ee) override;
};

class BillboardRenderSystem : public sp::ecs::System, public Render3DInterface<BillboardRenderer, true>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, BillboardRenderer& bbr) override;
};
