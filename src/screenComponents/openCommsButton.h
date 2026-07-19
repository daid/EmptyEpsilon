#pragma once

#include "gui/gui2_button.h"

class TargetsContainer;

class GuiOpenCommsButton : public GuiButton
{
    TargetsContainer* targets;
private:
    bool allow_comms = true;
public:
    GuiOpenCommsButton(GuiContainer* owner, string id, string name, TargetsContainer* targets, bool allow_comms = true);

    virtual void onDraw(sp::RenderTarget& target) override;
};
