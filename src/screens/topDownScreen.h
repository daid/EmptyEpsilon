#pragma once

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/viewport3d.h"
#include "screenComponents/radarView.h"

class GuiSelector;
class GuiToggleButton;
class GuiHotkeyHelpOverlay;

class TopDownScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    sp::ecs::Entity target;
    GuiSelector* camera_lock_selector;
    GuiToggleButton* camera_lock_toggle;
    GuiHotkeyHelpOverlay* keyboard_help;
public:
    TopDownScreen(RenderLayer* render_layer);

    virtual void update(float delta) override;
};
