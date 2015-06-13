#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

class ScreenMainScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
public:
    ScreenMainScreen();
    
    virtual void update(float delta);
    
    virtual void onClick(sf::Vector2f mouse_position);
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//MAIN_SCREEN_H
