#ifndef VIEWPORT_3D_H
#define VIEWPORT_3D_H

#include "gui/gui2_element.h"
#include "glObjects.h"

class GuiViewport3D : public GuiElement
{
    bool show_callsigns;
    bool show_headings;
    bool show_spacedust;

    double projection_matrix[16];
    double model_matrix[16];
    double viewport[4];

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
        Count
    };

    // Starbox
    std::array<uint32_t, static_cast<size_t>(Uniforms::StarboxCount)> starbox_uniforms;
    std::array<uint32_t, static_cast<size_t>(VertexAttributes::Count)> starbox_vertex_attributes;
    gl::Textures<1> starbox_texture;
    gl::Buffers<static_cast<size_t>(Buffers::StarboxCount)> starbox_buffers;
    sf::Shader* starbox_shader = nullptr;

    // Spacedust
    static constexpr size_t spacedust_particle_count = 1024;
    std::array<uint32_t, static_cast<size_t>(Uniforms::SpacedustCount)> spacedust_uniforms;
    uint32_t spacedust_vertex_hash_attribute = 0;
    gl::Buffers<static_cast<size_t>(Buffers::SpacedustCount)> spacedust_buffer;
    sf::Shader* spacedust_shader = nullptr;

    
#endif
public:
    GuiViewport3D(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);

    GuiViewport3D* showCallsigns() { show_callsigns = true; return this; }
    GuiViewport3D* showHeadings() { show_headings = true; return this; }
    GuiViewport3D* showSpacedust() { show_spacedust = true; return this; }
private:
    sf::Vector3f worldToScreen(sf::RenderTarget& window, sf::Vector3f world);
};

#endif//VIEWPORT_3D_H
