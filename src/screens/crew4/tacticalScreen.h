#pragma once

#include "gui/gui2_overlay.h"
#include "gui/joystickConfig.h"
#include "screenComponents/targetsContainer.h"

class AimLock;
class AimLockButton;
class GuiMissileTubeControls;
class GuiRadarView;

class TacticalScreen : public GuiOverlay
{
private:
    GuiOverlay* background_crosses;

    GuiElement* warp_controls;
    GuiElement* jump_controls;

    TargetsContainer targets;
    GuiRadarView* radar;
    AimLock* missile_aim;
    AimLockButton* lock_aim;
    GuiMissileTubeControls* tube_controls;
    bool drag_rotate;
    bool continuous_turning = false;
public:
    TacticalScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
