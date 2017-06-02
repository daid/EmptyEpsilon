#ifndef NOISE_OVERLAY_H
#define NOISE_OVERLAY_H

#include "gui/gui2_element.h"

class GuiNoiseOverlay : public GuiElement
{
public:
    GuiNoiseOverlay(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//NOISE_OVERLAY_H
