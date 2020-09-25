#ifndef VIEWPORT_MAIN_SCREEN_H
#define VIEWPORT_MAIN_SCREEN_H

#include "viewport3d.h"

class GuiViewportMainScreen : public GuiViewport3D
{
public:
    GuiViewportMainScreen(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);

    bool first_person = false;
};

#endif//VIEWPORT_MAIN_SCREEN_H
