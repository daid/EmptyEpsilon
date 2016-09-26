#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "threatLevelEstimate.h"

class GuiViewport3D;
class GuiRadarView;
class GuiCommsOverlay;

class ScreenMainScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
private:
    GuiViewport3D* viewport;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    bool first_person;
    GuiCommsOverlay* onscreen_comms;
    int impulse_sound = -1;
    DamageControlScreen*ship_state ;
public:
    ScreenMainScreen();
    
    virtual void update(float delta) override;
    
    virtual void onClick(sf::Vector2f mouse_position) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//MAIN_SCREEN_H
