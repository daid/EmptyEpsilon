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
    WindowScreen(float angle, uint8_t flags = 0x01);
    
    virtual void update(float delta) override;

    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
    
    constexpr static uint8_t flag_callsigns = 0x04;
    constexpr static uint8_t flag_headings  = 0x02;
    constexpr static uint8_t flag_spacedust = 0x01;
    
};

#endif//WINDOW_SCREEN_H
