#ifndef SHIP_LOG_SCREEN_H
#define SHIP_LOG_SCREEN_H

#include "gui/gui2.h"
#include "gui/gui2_advancedscrolltext.h"

class ShipLogScreen : public GuiOverlay
{
private:
    GuiAdvancedScrollText* log_text;
public:
    ShipLogScreen(GuiContainer* owner);
    
    void onDraw(sf::RenderTarget& window) override;
};

#endif//SHIP_LOG_SCREEN_H
