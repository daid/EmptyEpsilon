#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "engine.h"

#include "screenComponents/helpOverlay.h"

#include "gui/gui2_canvas.h"

class GuiViewport3D;
class GuiRadarView;
class GuiCommsOverlay;
class GuiHelpOverlay;
class Music;

class ScreenMainScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    GuiHelpOverlay* keyboard_help;
    string keyboard_general = "";
    GuiRadarView* tactical_radar;
    GuiRadarView* long_range_radar;
    bool first_person;
    GuiCommsOverlay* onscreen_comms;
    Music* music;
    int impulse_sound = -1;
public:
    ScreenMainScreen();
    
    virtual void update(float delta) override;
    
    virtual void playMusic(string filename);
    virtual void resetMusic();
    virtual void onClick(sf::Vector2f mouse_position) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//MAIN_SCREEN_H
