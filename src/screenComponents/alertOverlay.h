#ifndef ALERT_LEVEL_OVERLAY_H
#define ALERT_LEVEL_OVERLAY_H

#include "gui/gui2_element.h"

class GuiOverlay;
class GuiLabel;

class AlertLevelOverlay : public GuiElement
{
private:
    string alert_sprite;
public:
    AlertLevelOverlay(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//ALERT_LEVEL_OVERLAY_H
