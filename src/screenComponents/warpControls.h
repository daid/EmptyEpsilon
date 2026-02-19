#pragma once

#include "gui/gui2_element.h"

class GuiKeyValueDisplay;
class GuiSlider;

class GuiWarpControls : public GuiElement
{
private:
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    bool set_active = false;
public:
    GuiWarpControls(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
