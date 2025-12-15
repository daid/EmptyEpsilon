#pragma once

#include "gui/gui2_canvas.h"
#include "Updatable.h"

class GuiSelector;
class GuiBasicSlider;
class GuiSlider;
class GuiToggleButton;
class GuiLabel;

class OptionsMenu : public GuiCanvas, public Updatable
{
public:
    enum class ReturnTo
    {
        Main,
        ShipSelection,
        None
    };
private:
    GuiElement* container;
    GuiToggleButton* graphics_button;
    GuiToggleButton* audio_button;
    GuiToggleButton* interface_button;
    GuiElement* graphics_page;
    GuiElement* audio_page;
    GuiElement* interface_page;
    GuiBasicSlider* mouselook_sensitivity_slider;
    GuiLabel* mouselook_sensitivity_overlay_label;
    GuiSlider* sound_volume_slider;
    GuiSlider* music_volume_slider;
    GuiSlider* impulse_volume_slider;
    GuiLabel* sound_volume_overlay_label;
    GuiLabel* music_volume_overlay_label;

    GuiBasicSlider* graphics_fov_slider{};
    GuiLabel* graphics_fov_overlay_label{};

    std::vector<string> hotkey_categories;
    GuiLabel* impulse_volume_overlay_label;
    OptionsMenu::ReturnTo return_to;

    void setupInterfaceOptions(OptionsMenu::ReturnTo return_to);
    void setupGraphicsOptions();
    void setupAudioOptions();
public:
    OptionsMenu(ReturnTo return_to=ReturnTo::Main);

    virtual void update(float delta) override;
};
