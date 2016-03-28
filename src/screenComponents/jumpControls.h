#ifndef GUI_JUMP_CONTROLS_H
#define GUI_JUMP_CONTROLS_H

#include "gui/gui2.h"

class GuiJumpControls : public GuiElement
{
private:
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    GuiButton* button;
    GuiProgressbar* charge_bar;
public:
    GuiJumpControls(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_JUMP_CONTROLS_H
