#ifndef ALERT_LEVEL_OVERLAY_H
#define ALERT_LEVEL_OVERLAY_H

#include "gui/gui2_element.h"

class GuiOverlay;
class GuiLabel;

class AlertLevelOverlay : public GuiElement
{
private:
public:
    AlertLevelOverlay(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//ALERT_LEVEL_OVERLAY_H
