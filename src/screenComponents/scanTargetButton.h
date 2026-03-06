#pragma once

#include "gui/gui2_element.h"

class GuiButton;
class GuiProgressbar;
class TargetsContainer;

class GuiScanTargetButton : public GuiElement
{
private:
    TargetsContainer* targets;
    GuiButton* button;
    GuiProgressbar* progress;
    bool allow_scanning = true;
public:
    GuiScanTargetButton(GuiContainer* owner, string id, TargetsContainer* targets, bool allow_scanning=true);

    virtual void onUpdate() override;
    virtual void onDraw(sp::RenderTarget& target) override;
};
