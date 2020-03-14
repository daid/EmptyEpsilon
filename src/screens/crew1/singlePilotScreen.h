#ifndef SINGLE_PILOT_SCREEN_H
#define SINGLE_PILOT_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"

class GuiViewport3D;
class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class SinglePilotScreen : public GuiOverlay
{
private:
    GuiOverlay* background_gradient;
    GuiOverlay* background_crosses;

    GuiViewport3D* viewport;
    GuiElement* left_panel;

    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiKeyValueDisplay* shields_display;
    GuiElement* warp_controls;
    GuiElement* jump_controls;
    
    TargetsContainer targets;
    GuiRadarView* radar;
    GuiRotationDial* missile_aim;
    GuiMissileTubeControls* tube_controls;
    GuiToggleButton* lock_aim;
public:
    SinglePilotScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//SINGLE_PILOT_SCREEN_H
