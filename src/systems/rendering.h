#pragma once

#include <ecs/entity.h>
#include <ecs/query.h>
#include <ecs/system.h>
#include "components/collision.h"
#include "main.h"
#include <glm/geometric.hpp>

class Render3DInterface {
public:
    virtual void render3D(sp::ecs::Entity e) = 0;
};

class RenderSystem
{
public:
    template<typename T> static void add3DHandler(Render3DInterface* rif, bool transparent) {
        render_handlers.push_back({rif, &RenderSystem::findRenderObjects<T>, transparent});
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
        Render3DInterface* rif;
    };
    std::vector<std::vector<RenderEntry>> render_lists;

    template<typename T> void findRenderObjects(Render3DInterface* rif, bool transparent) {
        for(auto [entity, t, transform] : sp::ecs::Query<T, sp::Transform>())
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
            render_lists[render_list_index].push_back({entity, depth, transparent, rif});
        }
    }

    struct RenderHandler {
        Render3DInterface* rif;
        void (RenderSystem::* func)(Render3DInterface* rif, bool transparent);
        bool transparent;
    };
    static std::vector<RenderHandler> render_handlers;
};


class MeshRenderSystem : public sp::ecs::System, public Render3DInterface
{
public:
    MeshRenderSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;
};

class NebulaRenderSystem : public sp::ecs::System, public Render3DInterface
{
public:
    NebulaRenderSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;
};

class ExplosionRenderSystem : public sp::ecs::System, public Render3DInterface
{
public:
    ExplosionRenderSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;
};
