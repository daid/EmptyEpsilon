#ifndef GUI_JUMP_CONTROLS_H
#define GUI_JUMP_CONTROLS_H

#include "gui/gui2.h"

class GuiJumpControls : public GuiElement
{
private:
    GuiLabel* label;
    GuiSlider* slider;
    GuiButton* button;
public:
    GuiJumpControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_JUMP_CONTROLS_H
