#ifndef SCAN_TARGET_BUTTON_H
#define SCAN_TARGET_BUTTON_H

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
public:
    GuiScanTargetButton(GuiContainer* owner, string id, TargetsContainer* targets);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SCAN_TARGET_BUTTON_H
