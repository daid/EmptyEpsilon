#ifndef TOP_DOWN_SCREEN_H
#define TOP_DOWN_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

class GuiSelector;
class GuiToggleButton;

class TopDownScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    P<SpaceObject> target;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
public:
    TopDownScreen();

    virtual void update(float delta) override;

    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//TOP_DOWN_SCREEN_H
