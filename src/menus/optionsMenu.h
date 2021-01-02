#ifndef OPTIONS_MENU_H
#define OPTIONS_MENU_H

#include "gui/gui2_canvas.h"

class GuiAutoLayout;
class GuiSelector;
class GuiSlider;
class GuiLabel;

class OptionsMenu : public GuiCanvas
{
private:
    GuiAutoLayout* left_container;
    GuiAutoLayout* right_container;
    GuiSelector* options_pager;
    GuiAutoLayout* graphics_page;
    GuiAutoLayout* audio_page;
    GuiAutoLayout* interface_page;
    GuiSlider* sound_volume_slider;
    GuiSlider* music_volume_slider;
    GuiSlider* impulse_volume_slider;
    GuiLabel* sound_volume_overlay_label;
    GuiLabel* music_volume_overlay_label;
    GuiLabel* impulse_volume_overlay_label;
    GuiSelector* language_selection;
public:
    OptionsMenu();

    void onKey(sf::Event::KeyEvent key, int unicode);
};
#endif//OPTIONS_MENU_H
