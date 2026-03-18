#pragma once

#include "gui/gui2_element.h"
#include "glObjects.h"
#include "graphics/shader.h"

#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>

class GuiViewport3D : public GuiElement
{
    bool show_callsigns = false;
    bool show_headings = false;
    bool show_spacedust = false;

    glm::mat4 projection_matrix;
    glm::mat4 view_matrix;

    float base_fov; // set by main_screen_camera_fov preference on init
    float fov_modifier = 0.0f;

    enum class Uniforms : uint8_t
    {
        Projection = 0,
        View,
        GlobalBox,
        LocalBox,
        BoxLerp,

        StarboxCount,

        Rotation = StarboxCount,

        SpacedustCount
    };

    enum class Buffers : uint8_t
    {
        Vertex = 0,

        SpacedustCount,

        Element = SpacedustCount,
        StarboxCount
    };

    enum class VertexAttributes : uint8_t
    {
        Position = 0,
        StarboxCount,

        Sign = StarboxCount,
        SpacedustCount
    };

    // Starbox
    std::array<uint32_t, static_cast<size_t>(Uniforms::StarboxCount)> starbox_uniforms;
    std::array<uint32_t, static_cast<size_t>(VertexAttributes::StarboxCount)> starbox_vertex_attributes;
    gl::Buffers<static_cast<size_t>(Buffers::StarboxCount)> starbox_buffers;
    sp::Shader* starbox_shader = nullptr;

    // Spacedust
    static constexpr size_t spacedust_particle_count = 1024;
    std::array<uint32_t, static_cast<size_t>(Uniforms::SpacedustCount)> spacedust_uniforms;
    std::array<uint32_t, static_cast<size_t>(VertexAttributes::SpacedustCount)> spacedust_vertex_attributes;
    gl::Buffers<static_cast<size_t>(Buffers::SpacedustCount)> spacedust_buffer;
    sp::Shader* spacedust_shader = nullptr;

public:
    GuiViewport3D(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiViewport3D* showCallsigns() { show_callsigns = true; return this; }
    GuiViewport3D* toggleCallsigns() { show_callsigns = !show_callsigns; return this; }
    GuiViewport3D* showHeadings() { show_headings = true; return this; }
    GuiViewport3D* showSpacedust() { show_spacedust = true; return this; }

    float getModifiedFoV() { return base_fov + fov_modifier; }
    float getFoVModifier() { return fov_modifier; }
    float modifyFoV(float modifier) { fov_modifier = std::clamp(base_fov + modifier, 30.0f, 140.0f) - base_fov; return fov_modifier; }
private:
    glm::vec3 worldToScreen(sp::RenderTarget& window, glm::vec3 world);
};
