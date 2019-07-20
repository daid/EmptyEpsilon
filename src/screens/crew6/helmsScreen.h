#ifndef HELMS_SCREEN_H
#define HELMS_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/combatManeuver.h"
#include "gui/joystickConfig.h"

class GuiKeyValueDisplay;
class GuiLabel;

class HelmsScreen : public GuiOverlay
{
private:
    GuiOverlay* background_gradient;
    GuiOverlay* background_crosses;

    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiElement* warp_controls;
    GuiElement* jump_controls;
    GuiLabel* heading_hint;
    GuiCombatManeuver* combat_maneuver;
public:
    HelmsScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;
};

#endif//HELMS_SCREEN_H
