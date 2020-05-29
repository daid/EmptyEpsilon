#ifndef AIM_LOCK_H
#define AIM_LOCK_H

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_rotationdial.h"
#include "screenComponents/radarView.h"
//#include "P.h"
#include "spaceObjects/playerSpaceship.h"

class GuiMissileTubeControls;
class GuiRotationDial;
class AimLockButton : public GuiToggleButton
{
private:
    P<PlayerSpaceship> target_spaceship;
    GuiMissileTubeControls* tube_controls;
    GuiRotationDial* missile_aim;

public:
    AimLockButton(GuiContainer* owner, string id, GuiMissileTubeControls* tube_controls, GuiRotationDial* missile_aim, P<PlayerSpaceship> targetSpaceship);
    
    virtual void onHotkey(const HotkeyResult& key) override;
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){target_spaceship = targetSpaceship;}
private:
    void setAimLock(bool value);
};


class AimLock : public GuiRotationDial {
public:
    AimLock(GuiContainer* owner, string id, GuiRadarView* radar, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
private:
    GuiRadarView* radar;
};

#endif//AIM_LOCK_H
