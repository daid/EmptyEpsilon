#pragma once

#include <ecs/system.h>
#include <ecs/query.h>
#include <container/bitset.h>
#include <vectorUtils.h>
#include <graphics/renderTarget.h>
#include "components/collision.h"


template<typename T, int PRIO, int FLAGS> class RenderRadarInterface {
public:
    RenderRadarInterface();
    virtual void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, T& component) = 0;
};

class RadarRenderSystem {
public:
    template<typename T, int PRIO, int FLAGS> static void addHandler(RenderRadarInterface<T, PRIO, FLAGS>* rrif) {
        handlers.push_back({
            PRIO, FLAGS, rrif, [](sp::RenderTarget& renderer, void* interface) {
                auto rr = reinterpret_cast<RenderRadarInterface<T, PRIO, FLAGS>*>(interface);
                for(auto [entity, component, transform] : sp::ecs::Query<T, sp::Transform>()) {
                    if (!visible_objects.has(entity.getIndex())) continue;

                    auto radar_position = rotateVec2((transform.getPosition() - view_position) * current_scale, current_rotation_offset);
                    radar_position += radar_screen_center;
                    rr->renderOnRadar(renderer, entity, radar_position, current_scale, transform.getRotation() + current_rotation_offset, component);
                }
            }
        });
        std::sort(handlers.begin(), handlers.end(), [](const Handler& a, const Handler& b) {
            return a.priority < b.priority;
        });
    }

    static void render(sp::RenderTarget& renderer, glm::vec2 _radar_screen_center, float scale, glm::vec2 _view_position, float view_rotation, int flags, sp::Bitset _visible_objects) {
        radar_screen_center = _radar_screen_center;
        current_scale = scale;
        current_rotation_offset = -view_rotation;
        current_flags = flags;
        view_position = _view_position;
        visible_objects = _visible_objects;


        for(auto& handler : handlers) {
            if ((handler.flags & flags) == handler.flags)
                handler.func(renderer, handler.rrif);
        }
    }

    static constexpr int FlagNone = 0x00;
    static constexpr int FlagLongRange = 0x01;
    static constexpr int FlagShortRange = 0x02;
    static constexpr int FlagGM = 0x04;
    static int current_flags;
private:
    static float current_scale;
    static float current_rotation_offset;
    static glm::vec2 radar_screen_center;
    static glm::vec2 view_position;
    static sp::Bitset visible_objects;
    struct Handler {
        int priority;
        int flags;
        void* rrif;
        void(*func)(sp::RenderTarget&, void*);
    };
    static std::vector<Handler> handlers;
};

template<typename T, int PRIO, int FLAGS> RenderRadarInterface<T, PRIO, FLAGS>::RenderRadarInterface() { RadarRenderSystem::addHandler(this); }

#include "components/radar.h"
#include "components/name.h"
class BasicRadarRendering :
    public sp::ecs::System,
    public RenderRadarInterface<RadarTrace, 50, RadarRenderSystem::FlagNone>,
    public RenderRadarInterface<CallSign, 100, RadarRenderSystem::FlagNone> {
public:
    void update(float delta) override {}

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, RadarTrace& component) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, CallSign& component) override;
};
