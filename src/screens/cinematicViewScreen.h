#ifndef CINEMATIC_VIEW_SCREEN_H
#define CINEMATIC_VIEW_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "screenComponents/viewport3d.h"

class GuiSelector;
class GuiToggleButton;

class CinematicViewScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    P<SpaceObject> target;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
public:
    CinematicViewScreen();
    
    virtual void update(float delta);
    
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//CINEMATIC_VIEW_SCREEN_H
