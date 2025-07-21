#ifndef OPTIONS_MENU_H
#define OPTIONS_MENU_H

#include "gui/gui2_canvas.h"
#include "Updatable.h"

class GuiSelector;
class GuiBasicSlider;
class GuiSlider;
class GuiToggleButton;
class GuiLabel;

enum EOptionsReturnTo
{
    OR_Main,
    OR_ShipSelection,
    OR_None
};

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
    OptionsMenu(EOptionsReturnTo return_to=OR_Main);

    virtual void update(float delta) override;
};
#endif//OPTIONS_MENU_H
