#pragma once

#include "gui/gui2_overlay.h"
#include "gui/joystickConfig.h"
#include "screenComponents/targetsContainer.h"

class AimLock;
class AimLockButton;
class GuiKeyValueDisplay;
class GuiMissileTubeControls;
class GuiRadarView;

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
    AimLock* missile_aim;
    AimLockButton* lock_aim;
    GuiElement* beam_info_box;
public:
    WeaponsScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
