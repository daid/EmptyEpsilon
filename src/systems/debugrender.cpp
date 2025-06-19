#include "debugrender.h"


void DebugRenderSystem::update(float delta)
{
}

void DebugRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, sp::Physics& physics)
{
    //TODO: Render physics shape in 3D world.
}

void DebugRenderSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, sp::Physics& physics)
{
    glm::u8vec4 color{255, 255, 255, 128};
    switch(physics.getType())
    {
    case sp::Physics::Type::Sensor: color = {255,128,128,128}; break;
    case sp::Physics::Type::Dynamic: color = {255,255,255,128}; break;
    case sp::Physics::Type::Static: color = {128,255,128,128}; break;
    }
    switch(physics.getShape())
    {
    case sp::Physics::Shape::Circle:
        renderer.drawCircleOutline(screen_position, physics.getSize().x * scale, 1.0, {255, 255, 255, 128});
        break;
    case sp::Physics::Shape::Rectangle:
        {
            auto s0 = physics.getSize() * .5f * scale;
            auto s1 = glm::vec2{s0.x, -s0.y};
            auto p0 = screen_position + rotateVec2(s0, rotation);
            auto p1 = screen_position + rotateVec2(s1, rotation);
            auto p2 = screen_position - rotateVec2(s0, rotation);
            auto p3 = screen_position - rotateVec2(s1, rotation);
            std::vector<glm::vec2> points{p0, p1, p2, p3, p0};
            renderer.drawLine(points, {255, 255, 255, 128});
        }
        break;
    }
}
