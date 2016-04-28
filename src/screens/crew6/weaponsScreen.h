#ifndef WEAPONS_SCREEN_H
#define WEAPONS_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/radarView.h"
#include "screenComponents/targetsContainer.h"

class GuiMissileTubeControls;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class WeaponsScreen : public GuiOverlay
{
private:
    TargetsContainer targets;
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* front_shield_display;
    GuiKeyValueDisplay* rear_shield_display;
    GuiRadarView* radar;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;
    GuiToggleButton* lock_aim;
public:
    WeaponsScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//HELMS_SCREEN_H
