#include "debugrender.h"
#include "gui/hotkeyConfig.h"
#include <graphics/opengl.h>
#include <glm/gtc/type_ptr.hpp>


DebugRenderSystem::DebugRenderSystem()
{
#ifdef DEBUG
    show_colliders = true;
#endif
}

void DebugRenderSystem::update(float delta)
{
#ifdef DEBUG
    if (keys.debug_show_colliders.getDown()) show_colliders = !show_colliders;
#endif
}

void DebugRenderSystem::render3D(sp::ecs::Entity e, sp::Transform& transform, sp::Physics& physics)
{
    if (!show_colliders) return;

    ShaderRegistry::ScopedShader color_shader(ShaderRegistry::Shaders::BasicColor);

    glDisable(GL_DEPTH_TEST);
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ transform.getPosition(), 0.0f });
    model_matrix = glm::rotate(model_matrix, glm::radians(transform.getRotation()), glm::vec3{ 0.f, 0.f, 1.f });

    glUniformMatrix4fv(color_shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));
    glUniform4f(color_shader.get().uniform(ShaderRegistry::Uniforms::Color), 1.0f, 1.0f, 1.0f, .5f);
    
    if (physics.getShape() == sp::Physics::Shape::Circle)
    {
        gl::ScopedVertexAttribArray positions(color_shader.get().attribute(ShaderRegistry::Attributes::Position));
        constexpr size_t point_count = 50;
        std::vector<glm::vec3> vertices;
        std::vector<uint16_t> indices;
        auto radius = physics.getSize().x;
        for(size_t idx=0; idx<point_count; idx++) {
            float f = float(idx) / float(point_count) * static_cast<float>(M_PI) * 2.0f;
            vertices.push_back({std::sin(f) * radius, std::cos(f) * radius, 0.0f});
            indices.push_back(idx);
        }
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, 0, reinterpret_cast<GLvoid*>(&vertices[0]));
        
        glDrawElements(GL_LINE_LOOP, point_count, GL_UNSIGNED_SHORT, reinterpret_cast<GLvoid*>(&indices[0]));
    }
    else if (physics.getShape() == sp::Physics::Shape::Rectangle)
    {
        gl::ScopedVertexAttribArray positions(color_shader.get().attribute(ShaderRegistry::Attributes::Position));
        std::vector<glm::vec3> vertices;
        std::vector<uint16_t> indices{0, 1, 2, 3};

        auto s0 = physics.getSize() * .5f;
        vertices.push_back(glm::vec3{s0.x, s0.y, 0.0f});
        vertices.push_back(glm::vec3{s0.x, -s0.y, 0.0f});
        vertices.push_back(glm::vec3{-s0.x, -s0.y, 0.0f});
        vertices.push_back(glm::vec3{-s0.x, s0.y, 0.0f});
        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, 0, reinterpret_cast<GLvoid*>(&vertices[0]));
        glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_SHORT, reinterpret_cast<GLvoid*>(&indices[0]));
    }
    glEnable(GL_DEPTH_TEST);
}

void DebugRenderSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, sp::Physics& physics)
{
    if (!show_colliders) return;

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
