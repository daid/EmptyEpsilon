#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/viewport3d.h"

class ScreenMainScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
public:
    ScreenMainScreen();
    
    virtual void update(float delta);
    
    virtual void onClick(sf::Vector2f mouse_position);
};

#endif//MAIN_SCREEN_H
