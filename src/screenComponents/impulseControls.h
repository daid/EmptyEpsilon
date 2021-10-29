#ifndef IMPULSE_CONTROLS_H
#define IMPULSE_CONTROLS_H

#include "gui/gui2_element.h"

class GuiKeyValueDisplay;
class GuiSlider;

class GuiImpulseControls : public GuiElement
{
private:
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    bool set_active = false;
public:
    GuiImpulseControls(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//IMPULSE_CONTROLS_H
