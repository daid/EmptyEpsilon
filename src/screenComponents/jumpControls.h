#pragma once

#include "gui/gui2_element.h"

class GuiKeyValueDisplay;
class GuiSlider;
class GuiButton;
class GuiProgressbar;

class GuiJumpControls : public GuiElement
{
private:
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    GuiButton* button;
    GuiProgressbar* charge_bar;
    bool set_active = false;
public:
    GuiJumpControls(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
