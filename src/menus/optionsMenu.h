#ifndef OPTIONS_MENU_H
#define OPTIONS_MENU_H

#include "gui/gui2_canvas.h"

class GuiSlider;
class GuiLabel;

class OptionsMenu : public GuiCanvas
{
private:
    GuiSlider* sound_volume_slider;
    GuiSlider* music_volume_slider;
    GuiLabel* sound_volume_overlay_label;
    GuiLabel* music_volume_overlay_label;

    std::vector<string> HotKeyCategories;
public:
    OptionsMenu();

    void onKey(sf::Event::KeyEvent key, int unicode);
};
#endif//OPTIONS_MENU_H
