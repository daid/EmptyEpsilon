#ifndef SINGLE_PILOT_VIEW_H
#define SINGLE_PILOT_VIEW_H

#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"

class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;

class SinglePilotView : public GuiElement
{
private:
    P<PlayerSpaceship>& target_spaceship;
    GuiOverlay* background_gradient;

    GuiKeyValueDisplay* heat_display;
    GuiKeyValueDisplay* hull_display;
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
    SinglePilotView(GuiContainer* owner, P<PlayerSpaceship>& targetSpaceship);
    
    void setTargetSpaceship(P<PlayerSpaceship>& targetSpaceship) { target_spaceship = targetSpaceship;}
    virtual void onDraw(sf::RenderTarget& window);
    virtual void onHotkey(const HotkeyResult& key) override;
};

#endif//SINGLE_PILOT_VIEW_H
