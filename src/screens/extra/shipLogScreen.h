#ifndef SHIP_LOG_SCREEN_H
#define SHIP_LOG_SCREEN_H

#include "screens/baseShipScreen.h"

class GuiAdvancedScrollText;
class GuiCustomShipFunctions;

class ShipLogScreen : public BaseShipScreen
{
private:
    GuiAdvancedScrollText* log_text;
    GuiCustomShipFunctions* custom_function_sidebar;
public:
    ShipLogScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
};

#endif//SHIP_LOG_SCREEN_H
