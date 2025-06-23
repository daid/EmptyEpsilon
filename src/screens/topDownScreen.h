#ifndef TOP_DOWN_SCREEN_H
#define TOP_DOWN_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/helpOverlay.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

class GuiSelector;
class GuiToggleButton;
class GuiHelpOverlay;

class TopDownScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    sp::ecs::Entity target;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
    GuiHelpOverlay* keyboard_help;
public:
    TopDownScreen(RenderLayer* render_layer);

    virtual void update(float delta) override;
};

#endif//TOP_DOWN_SCREEN_H
