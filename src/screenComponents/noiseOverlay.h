#ifndef GUI_NOISE_OVERLAY_H
#define GUI_NOISE_OVERLAY_H

#include "gui/gui2_element.h"

class GuiNoiseOverlay : public GuiElement
{
public:
    GuiNoiseOverlay(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_NOISE_OVERLAY_H
