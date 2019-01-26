#ifndef IMPULSE_CONTROLS_H
#define IMPULSE_CONTROLS_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"

class GuiKeyValueDisplay;
class GuiSlider;
class GuiPowerDamageIndicator;

class GuiImpulseControls : public GuiElement
{
private:
    P<PlayerSpaceship> target_spaceship;
    GuiKeyValueDisplay* label;
    GuiSlider* slider;
    GuiPowerDamageIndicator* pdi;
public:
    GuiImpulseControls(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship);

};

#endif//IMPULSE_CONTROLS_H
