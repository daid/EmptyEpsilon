#ifndef HELMS_SCREEN_H
#define HELMS_SCREEN_H

#include "gui/gui2.h"

class HelmsScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiElement* warp_controls;
    GuiElement* jump_controls;
    GuiLabel* heading_hint;
public:
    HelmsScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//HELMS_SCREEN_H
