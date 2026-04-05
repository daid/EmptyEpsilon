#pragma once

#include "optionsMenu.h"
#include "gui/hotkeyBinder.h"
#include "Updatable.h"

class GuiCanvas;
class GuiHotkeyBinder;
class GuiLabel;
class GuiOverlay;
class GuiPanel;
class GuiScrollContainer;
class GuiScrollText;
class GuiSlider;

class HotkeyMenu : public GuiCanvas, public Updatable
{
private:
    const float ROW_HEIGHT = 50.0f;
    const float FRAME_MARGIN = 50.0f;
    const float KEY_LABEL_WIDTH = 400.0f;
    const float KEY_BINDER_MARGIN = 12.5f;
    const float RESET_LABEL_TIMEOUT = 5.0f;

    GuiScrollText* help_text;
    GuiElement* container;
    GuiElement* top_row;
    GuiPanel* rebinding_ui;
    GuiElement* bottom_row;

    GuiScrollContainer* scroll_container;
    GuiElement* info_container;
    std::vector<GuiElement*> rebinding_rows;
    std::vector<GuiHotkeyBinder*> text_entries;
    std::vector<GuiLabel*> label_entries;
    GuiLabel* reset_label;

    string category = "";
    int category_index = 1;
    float reset_label_timer = 0.0f;
    std::vector<string> category_list;
    std::vector<sp::io::Keybinding*> hotkey_list;
    OptionsMenu::ReturnTo return_to;

    void setCategory(int cat);
public:
    HotkeyMenu(OptionsMenu::ReturnTo return_to=OptionsMenu::ReturnTo::Main);

    virtual void update(float delta) override;
};
