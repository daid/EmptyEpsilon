#ifndef GUI_IMPULSE_CONTROLS_H
#define GUI_IMPULSE_CONTROLS_H

#include "gui/gui2.h"

class GuiImpulseControls : public GuiElement
{
private:
    GuiLabel* label;
public:
    GuiImpulseControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_IMPULSE_CONTROLS_H
