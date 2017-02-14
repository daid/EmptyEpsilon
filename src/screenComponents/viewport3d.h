#ifndef VIEWPORT_3D_H
#define VIEWPORT_3D_H

#include "gui/gui2_element.h"

class GuiViewport3D : public GuiElement
{
    bool show_callsigns;
    bool show_headings;
    bool show_spacedust;

    double projection_matrix[16];
    double model_matrix[16];
    double viewport[4];
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
