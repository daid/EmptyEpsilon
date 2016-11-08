#ifndef OPEN_COMMS_BUTTON_H
#define OPEN_COMMS_BUTTON_H

#include "gui/gui2_button.h"

class TargetsContainer;

class GuiOpenCommsButton : public GuiButton
{
    TargetsContainer* targets;
public:
    GuiOpenCommsButton(GuiContainer* owner, string id, TargetsContainer* targets);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//OPEN_COMMS_BUTTON_H
