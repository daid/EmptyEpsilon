#ifndef JUMP_INDICATOR_H
#define JUMP_INDICATOR_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiLabel;

class GuiJumpIndicator : public GuiElement
{
private:
    GuiPanel* box;
    GuiLabel* label;
public:
    GuiJumpIndicator(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//JUMP_INDICATOR_H
