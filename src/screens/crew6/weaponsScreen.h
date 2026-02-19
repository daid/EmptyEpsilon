#pragma once

#include "gui/gui2_overlay.h"
#include "screenComponents/radarView.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiMissileTubeControls;
class GuiKeyValueDisplay;
class GuiLabel;
class GuiToggleButton;
class GuiRotationDial;

class WeaponsScreen : public GuiOverlay
{
private:
    GuiOverlay* background_crosses;

    TargetsContainer targets;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* front_shield_display;
    GuiKeyValueDisplay* rear_shield_display;
    GuiRadarView* radar;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;
    GuiToggleButton* lock_aim;
    GuiElement* beam_shield_box;
    GuiLabel* beam_label;
    GuiElement* beam_frequency_row;
    GuiLabel* beam_frequency_label;
    GuiElement* beam_system_row;
    GuiLabel* beam_system_label;
    GuiLabel* shield_label;
public:
    WeaponsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
