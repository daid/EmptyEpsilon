#ifndef HELMS_SCREEN_H
#define HELMS_SCREEN_H

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

    GuiElement* warp_controls;
    GuiElement* jump_controls;
    GuiLabel* heading_hint;
    GuiCombatManeuver* combat_maneuver;
    GuiDockingButton* docking_button;

    float turn_request = 0.0f;
public:
    HelmsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//HELMS_SCREEN_H
