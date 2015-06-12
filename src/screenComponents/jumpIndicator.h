#ifndef GUI_JUMP_INDICATOR_H
#define GUI_JUMP_INDICATOR_H

#include "gui/gui2.h"

class GuiJumpIndicator : public GuiElement
{
private:
    GuiBox* box;
    GuiLabel* label;
public:
    GuiJumpIndicator(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SELF_DESTRUCT_INDICATOR_H
