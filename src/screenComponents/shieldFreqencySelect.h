#ifndef SHIELD_FREQUENCY_SELECT_H
#define SHIELD_FREQUENCY_SELECT_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"

class GuiKeyValueDisplay;
class GuiSelector;
class GuiButton;
class GuiProgressbar;

class GuiShieldFrequencySelect : public GuiElement
{
private:
    P<PlayerSpaceship> target_spaceship;
    GuiSelector* new_frequency;
    GuiButton* calibrate_button;
public:
    GuiShieldFrequencySelect(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship);
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){target_spaceship = targetSpaceship;}
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//SHIELD_FREQUENCY_SELECT_H
