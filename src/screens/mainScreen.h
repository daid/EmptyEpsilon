#include <memory>
#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"
#include "screenComponents/helpOverlay.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "threatLevelEstimate.h"
#include "screenComponents/databaseView.h"

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
    string keyboard_general = "";
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    DatabaseViewComponent* database_view;
    GuiLabel* database_no_entry_text;
    GuiCommsOverlay* onscreen_comms;
    std::unique_ptr<ImpulseSound> impulse_sound;
public:
    ScreenMainScreen();

    virtual void update(float delta) override;

    virtual void onClick(sf::Vector2f mouse_position) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//MAIN_SCREEN_H
