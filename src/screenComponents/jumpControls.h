#ifndef JUMP_CONTROLS_H
#define JUMP_CONTROLS_H

#include "gui/gui2_element.h"

class PlayerSpaceship;
class GuiKeyValueDisplay;
class GuiSlider;
class GuiButton;
class GuiProgressbar;

class GuiJumpControls : public GuiElement
{
private:
    P<PlayerSpaceship>& target_spaceship;
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    GuiButton* button;
    GuiProgressbar* charge_bar;
public:
    GuiJumpControls(GuiContainer* owner, string id, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//JUMP_CONTROLS_H
