#ifndef COMBAT_MANEUVER_H
#define COMBAT_MANEUVER_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"

class GuiSnapSlider2D;
class GuiProgressbar;
class GuiPowerDamageIndicator;

class GuiCombatManeuver : public GuiElement
{
private:
    P<PlayerSpaceship> target_spaceship;
    GuiSnapSlider2D* slider;
    GuiProgressbar* charge_bar;
    GuiPowerDamageIndicator* strafe_pdi;
    GuiPowerDamageIndicator* boost_pdi;
public:
    GuiCombatManeuver(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship);
    
    virtual void onUpdate() override;
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    
    void setBoostValue(float value);
    void setStrafeValue(float value);
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship);
};

#endif//COMBAT_MANEUVER_H
