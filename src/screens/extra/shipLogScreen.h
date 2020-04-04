#ifndef SHIP_LOG_SCREEN_H
#define SHIP_LOG_SCREEN_H

#include "gui/gui2_overlay.h"

class GuiAdvancedScrollText;
class GuiCustomShipFunctions;

class ShipLogScreen : public GuiOverlay
{
private:
    GuiAdvancedScrollText* log_text;
    GuiCustomShipFunctions* custom_function_sidebar;
public:
    ShipLogScreen(GuiContainer* owner);
    
    void onDraw(sf::RenderTarget& window) override;
};

#endif//SHIP_LOG_SCREEN_H
