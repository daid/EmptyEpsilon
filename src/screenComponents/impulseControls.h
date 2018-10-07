#ifndef IMPULSE_CONTROLS_H
#define IMPULSE_CONTROLS_H

#include "gui/gui2_element.h"

class PlayerSpaceship;
class GuiKeyValueDisplay;
class GuiSlider;

class GuiImpulseControls : public GuiElement
{
private:
    P<PlayerSpaceship>& target_spaceship;
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
public:
    GuiImpulseControls(GuiContainer* owner, string id, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//IMPULSE_CONTROLS_H
