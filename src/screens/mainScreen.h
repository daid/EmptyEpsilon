#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "threatLevelEstimate.h"

class GuiViewport3D;
class GuiRadarView;

class ScreenMainScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
private:
    GuiViewport3D* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    bool first_person;
public:
    ScreenMainScreen();
    
    virtual void update(float delta);
    
    virtual void onClick(sf::Vector2f mouse_position);
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//MAIN_SCREEN_H
