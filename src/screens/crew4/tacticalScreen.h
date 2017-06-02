#ifndef TACTICAL_SCREEN_H
#define TACTICAL_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"

class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class TacticalScreen : public GuiOverlay
{
private:
    GuiOverlay* background_gradient;
    GuiOverlay* background_crosses;

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
    TacticalScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//TACTICAL_SCREEN_H
