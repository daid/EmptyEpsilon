#pragma once

#include "gui/gui2_overlay.h"
#include "gui/joystickConfig.h"
#include "screenComponents/radarView.h"

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
    GuiRadarView* radar;
public:
    HelmsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
