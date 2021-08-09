#ifndef OPEN_COMMS_BUTTON_H
#define OPEN_COMMS_BUTTON_H

#include "gui/gui2_button.h"

class TargetsContainer;

class GuiOpenCommsButton : public GuiButton
{
    TargetsContainer* targets;
public:
    GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets);

    virtual void onDraw(sp::RenderTarget& target);
};

#endif//OPEN_COMMS_BUTTON_H
