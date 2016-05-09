#ifndef TOP_DOWN_SCREEN_H
#define TOP_DOWN_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

class TopDownScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    P<SpaceObject> target;
public:
    TopDownScreen();
    
    virtual void update(float delta);
    
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//TOP_DOWN_SCREEN_H
