#pragma once

#include "optionsMenu.h"
#include "gui/gui2_arrowbutton.h"
#include "gui/gui2_canvas.h"
#include "gui/hotkeyBinder.h"
#include "Updatable.h"
#include <timer.h>

class GuiArrowButton;
class GuiButton;
class GuiLabel;
class GuiCanvas;
class GuiPanel;
class GuiScrollText;
class GuiSelector;
class GuiToggleButton;
class GuiHotkeyBinder;

class HotkeyMenu : public GuiCanvas, public Updatable
{
private:
    const float ROW_HEIGHT = 50.0f;
    const float FRAME_MARGIN = 50.0f;
    const float KEY_LABEL_WIDTH = 250.0f;
    const float KEY_BINDER_WIDTH = 250.0f;
    const float KEY_BINDER_MARGIN = 10.0f;
    const float KEY_LABEL_MARGIN = 25.0f;
    const int KEY_ROW_COUNT = 6;
    const float RESET_LABEL_TIMEOUT = 5.0f;

    // Column width: label + 3 binders + margins between them
    const float KEY_COLUMN_WIDTH = KEY_LABEL_WIDTH + KEY_LABEL_MARGIN + 3.0f * KEY_BINDER_WIDTH + 4.0f * KEY_BINDER_MARGIN;
    // Row height: binding display + add/remove/invert buttons
    const float KEY_ROW_HEIGHT = ROW_HEIGHT + GuiHotkeyBinder::SELECTOR_HEIGHT;
    const float KEY_COLUMN_HEIGHT = KEY_ROW_HEIGHT * KEY_ROW_COUNT + FRAME_MARGIN * 2.0f;
    const float KEY_COLUMN_TOP = ROW_HEIGHT * 1.5f + ROW_HEIGHT * 0.5f; // top_row + header_row

    GuiScrollText* help_text;
    GuiElement* container;
    GuiElement* top_row;
    GuiPanel* rebinding_ui;
    GuiElement* bottom_row;

    GuiElement* rebinding_container;
    GuiElement* info_container;
    std::vector<GuiElement*> rebinding_columns;
    std::vector<GuiElement*> rebinding_rows;
    std::vector<GuiHotkeyBinder*> text_entries;
    std::vector<GuiLabel*> label_entries;
    GuiArrowButton* previous_page;
    GuiArrowButton* next_page;
    GuiLabel* reset_label;

    string category = "";
    int category_index = 0;
    sp::SystemTimer reset_label_timer;
    std::vector<string> category_list;
    std::vector<sp::io::Keybinding*> hotkey_list;
    OptionsMenu::ReturnTo return_to;

    GuiSelector* category_selector;

    // Rebind dialog
    GuiRebindDialog* rebind_dialog;

    void setCategory(int cat);
    void pageHotkeys(int direction);
public:
    HotkeyMenu(OptionsMenu::ReturnTo return_to=OptionsMenu::ReturnTo::Main);

    virtual void update(float delta) override;
};
