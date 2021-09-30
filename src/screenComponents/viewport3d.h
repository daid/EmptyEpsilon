#ifndef VIEWPORT_3D_H
#define VIEWPORT_3D_H

#include "gui/gui2_element.h"
#include "glObjects.h"

#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>

class GuiViewport3D : public GuiElement
{
    bool show_callsigns;
    bool show_headings;
    bool show_spacedust;

    glm::mat4 projection_matrix;
    glm::mat4 model_matrix;
    glm::vec4 viewport;

#if FEATURE_3D_RENDERING
    enum class Uniforms : uint8_t
    {
        Projection = 0,
        ModelView,

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
    gl::Textures<1> starbox_texture;
    gl::Buffers<static_cast<size_t>(Buffers::StarboxCount)> starbox_buffers;
    sp::Shader* starbox_shader = nullptr;

    // Spacedust
    static constexpr size_t spacedust_particle_count = 1024;
    std::array<uint32_t, static_cast<size_t>(Uniforms::SpacedustCount)> spacedust_uniforms;
    std::array<uint32_t, static_cast<size_t>(VertexAttributes::SpacedustCount)> spacedust_vertex_attributes;
    gl::Buffers<static_cast<size_t>(Buffers::SpacedustCount)> spacedust_buffer;
    sp::Shader* spacedust_shader = nullptr;

    
#endif
public:
    GuiViewport3D(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target);

    GuiViewport3D* showCallsigns() { show_callsigns = true; return this; }
    GuiViewport3D* showHeadings() { show_headings = true; return this; }
    GuiViewport3D* showSpacedust() { show_spacedust = true; return this; }
private:
    glm::vec3 worldToScreen(sp::RenderTarget& window, glm::vec3 world);
};

#endif//VIEWPORT_3D_H
