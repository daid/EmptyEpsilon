#ifndef HELMS_SCREEN_H
#define HELMS_SCREEN_H

#include "gui/gui2.h"

class HelmsScreen : public GuiOverlay
{
public:
    HelmsScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//HELMS_SCREEN_H
