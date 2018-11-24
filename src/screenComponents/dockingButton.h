#ifndef DOCKING_BUTTON_H
#define DOCKING_BUTTON_H

#include "gui/gui2_button.h"
class PlayerSpaceship;
class SpaceObject;
class GuiDockingButton : public GuiButton
{
private:
    P<PlayerSpaceship>& target_spaceship;

public:
    GuiDockingButton(GuiContainer* owner, string id, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual void onHotkey(const HotkeyResult& key) override;
private:
    void click();
    
    P<SpaceObject> findDockingTarget();
};

#endif//DOCKING_BUTTON_H
