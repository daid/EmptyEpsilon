#ifndef SINGLE_PILOR_SCREEN_H
#define SINGLE_PILOR_SCREEN_H

#include "gui/gui2.h"
#include "screenComponents/targetsContainer.h"

class GuiViewport3D;
class GuiMissileTubeControls;
class GuiRadarView;
class SinglePilotScreen : public GuiOverlay
{
private:
    GuiViewport3D* viewport;

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
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//ENGINEERING_ADVANCED_SCREEN_H

