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

        Count
    };

    enum class Buffers : uint8_t
    {
        Vertex = 0,
        Element,

        Count
    };

    enum class VertexAttributes : uint8_t
    {
        Position = 0,
        Count
    };

    std::array<uint32_t, static_cast<size_t>(Uniforms::Count)> starbox_uniforms;
    std::array<uint32_t, static_cast<size_t>(Uniforms::Count)> starbox_vertex_attributes;
    gl::Textures<1> starbox_texture;
    gl::Buffers<static_cast<size_t>(Buffers::Count)> starbox_buffers;
    sf::Shader* starbox_shader = nullptr;
    
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
