#ifndef SHIELDS_ENABLE_BUTTON_H
#define SHIELDS_ENABLE_BUTTON_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"

class GuiToggleButton;
class GuiProgressbar;
class GuiPowerDamageIndicator;

class GuiShieldsEnableButton : public GuiElement
{
private:
    P<PlayerSpaceship> target_spaceship;
    GuiToggleButton* button;
    GuiProgressbar* bar;
    GuiPowerDamageIndicator* pdi;
public:
    GuiShieldsEnableButton(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship);

};

#endif//SHIELDS_ENABLE_BUTTON_H
