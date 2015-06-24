#ifndef GUI_WARP_CONTROLS_H
#define GUI_WARP_CONTROLS_H

#include "gui/gui2.h"

class GuiWarpControls : public GuiElement
{
private:
    GuiLabel* label;
    GuiSlider* slider;
public:
    GuiWarpControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_WARP_CONTROLS_H
