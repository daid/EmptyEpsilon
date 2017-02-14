#ifndef WINDOW_SCREEN_H
#define WINDOW_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"

class GuiViewport3D;

class WindowScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    float angle;
public:
    WindowScreen(float angle);
    
    virtual void update(float delta) override;

    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//WINDOW_SCREEN_H
