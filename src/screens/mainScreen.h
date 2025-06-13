#include <memory>
#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "screenComponents/helpOverlay.h"
#include "gui/gui2_canvas.h"
#include "threatLevelEstimate.h"

class GuiViewportMainScreen;
class GuiRadarView;
class GuiCommsOverlay;
class GuiHelpOverlay;
class ImpulseSound;

class ScreenMainScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
private:
    GuiViewportMainScreen* viewport;
    GuiHelpOverlay* keyboard_help;
    GuiRadarView* main_screen_radar;
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    GuiCommsOverlay* onscreen_comms;
    std::unique_ptr<ImpulseSound> impulse_sound;
public:
    ScreenMainScreen(RenderLayer* render_layer);

    virtual void destroy() override;

    virtual void update(float delta) override;

    virtual bool onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//MAIN_SCREEN_H
