#ifndef GUI_SCAN_TARGET_BUTTON_H
#define GUI_SCAN_TARGET_BUTTON_H

#include "targetsContainer.h"
#include "gui/gui2.h"

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

#endif//GUI_SCAN_TARGET_BUTTON_H
