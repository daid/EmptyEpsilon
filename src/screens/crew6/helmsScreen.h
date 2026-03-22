#pragma once

#include "screens/baseShipScreen.h"
#include "gui/joystickConfig.h"

class GuiKeyValueDisplay;
class GuiLabel;
class GuiDockingButton;
class GuiCombatManeuver;

class HelmsScreen : public BaseShipScreen
{
private:
    GuiLabel* heading_hint;
    GuiCombatManeuver* combat_maneuver;
    GuiDockingButton* docking_button;
public:
    HelmsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
