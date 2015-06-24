#ifndef WEAPONS_SCREEN_H
#define WEAPONS_SCREEN_H

#include "gui/gui2.h"

class WeaponsScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* shields_display;
public:
    WeaponsScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//HELMS_SCREEN_H
