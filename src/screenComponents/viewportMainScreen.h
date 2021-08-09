#ifndef VIEWPORT_MAIN_SCREEN_H
#define VIEWPORT_MAIN_SCREEN_H

#include "viewport3d.h"

class GuiViewportMainScreen : public GuiViewport3D
{
public:
    GuiViewportMainScreen(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target);

    bool first_person = false;

    constexpr static uint8_t flag_callsigns = 0x04;
    constexpr static uint8_t flag_headings  = 0x02;
    constexpr static uint8_t flag_spacedust = 0x01;
};

#endif//VIEWPORT_MAIN_SCREEN_H
