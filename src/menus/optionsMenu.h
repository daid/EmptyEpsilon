#ifndef OPTIONS_MENU_H
#define OPTIONS_MENU_H

#include "gui/gui2_canvas.h"
#include "Updatable.h"

class GuiSelector;
class GuiBasicSlider;
class GuiSlider;
class GuiToggleButton;
class GuiLabel;

class OptionsMenu : public GuiCanvas, public Updatable
{
private:
    GuiElement* container;
    GuiToggleButton* graphics_button;
    GuiToggleButton* audio_button;
    GuiToggleButton* interface_button;
    GuiElement* graphics_page;
    GuiElement* audio_page;
    GuiElement* interface_page;
    GuiSlider* sound_volume_slider;
    GuiSlider* music_volume_slider;
    GuiSlider* impulse_volume_slider;
    GuiLabel* sound_volume_overlay_label;
    GuiLabel* music_volume_overlay_label;

    GuiBasicSlider* graphics_fov_slider{};
    GuiLabel* graphics_fov_overlay_label{};

    std::vector<string> hotkey_categories;
    GuiLabel* impulse_volume_overlay_label;

    void setupGraphicsOptions();
    void setupAudioOptions();
public:
    enum class ReturnTo
    {
        OR_Main,          // Return to Main Menu
        OR_ShipSelection, // Return to Ship Selection
        OR_None
    };

    OptionsMenu(ReturnTo return_to=ReturnTo::OR_Main);

    virtual void update(float delta) override;
};
#endif//OPTIONS_MENU_H
