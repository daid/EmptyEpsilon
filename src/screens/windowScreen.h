#ifndef WINDOW_SCREEN_H
#define WINDOW_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/viewport3d.h"

class WindowScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    float angle;
public:
    WindowScreen(float angle);
    
    virtual void update(float delta);

    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//MAIN_SCREEN_H
