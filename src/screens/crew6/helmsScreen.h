#pragma once

#include "gui/gui2_overlay.h"
#include "gui/joystickConfig.h"

class GuiKeyValueDisplay;
class GuiLabel;
class GuiDockingButton;
class GuiCombatManeuver;

class HelmsScreen : public GuiOverlay
{
private:
    GuiOverlay* background_crosses;

    GuiLabel* heading_hint;
    GuiCombatManeuver* combat_maneuver;
    GuiDockingButton* docking_button;

    float turn_request = 0.0f;
public:
    HelmsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
