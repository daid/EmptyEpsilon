#ifndef SPECTATOR_SCREEN_H
#define SPECTATOR_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/targetsContainer.h"


class GuiRadarView;
class SpectatorScreen : public GuiCanvas, public Updatable
{
private:
    GuiRadarView* main_radar;
    TargetsContainer targets;

    sf::Vector2f drag_start_position;
    sf::Vector2f drag_previous_position;
public:
    SpectatorScreen();
    virtual ~SpectatorScreen();
    
    virtual void update(float delta);
    
    void onMouseDown(sf::Vector2f position);
    void onMouseDrag(sf::Vector2f position);
    void onMouseUp(sf::Vector2f position);

    void onKey(sf::Event::KeyEvent key, int unicode);
};


#endif//SPECTATOR_SCREEN_H
