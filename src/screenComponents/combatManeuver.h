#ifndef GUI_COMBAT_MANEUVER_H
#define GUI_COMBAT_MANEUVER_H

#include "gui/gui2.h"

class GuiCombatManeuver : public GuiElement
{
public:
    GuiProgressbar* charge_bar;
public:
    GuiCombatManeuver(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_COMBAT_MANEUVER_H
