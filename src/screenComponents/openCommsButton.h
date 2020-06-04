#ifndef OPEN_COMMS_BUTTON_H
#define OPEN_COMMS_BUTTON_H

#include "gui/gui2_button.h"
#include "spaceObjects/playerSpaceship.h"

class TargetsContainer;

class GuiOpenCommsButton : public GuiButton
{
    TargetsContainer* targets;
private:
    P<PlayerSpaceship> target_spaceship;
public:
    GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets, P<PlayerSpaceship> targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//OPEN_COMMS_BUTTON_H
