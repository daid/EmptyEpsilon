#ifndef TACTICAL_SCREEN_H
#define TACTICAL_SCREEN_H

#include "gui/gui2.h"
#include "screenComponents/targetsContainer.h"

class GuiMissileTubeControls;
class GuiRadarView;
class TacticalScreen : public GuiOverlay
{
private:
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
};

#endif//TACTICAL_SCREEN_H
