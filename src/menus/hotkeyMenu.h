#ifndef HOTKEYMENU_H
#define HOTKEYMENU_H

#include "gui/gui2_arrowbutton.h"
#include "gui/gui2_entrylist.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_scrollbar.h"
#include "gui/hotkeyBinder.h"

class GuiArrowButton;
class GuiAutoLayout;
class GuiOverlay;
class GuiSlider;
class GuiLabel;
class GuiCanvas;
class GuiPanel;
class GuiScrollText;
class GuiHotkeyBinder;

class HotkeyMenu : public GuiCanvas
{
private:
    const int ROW_HEIGHT = 50;
    const int FRAME_MARGIN = 50;
    const int KEY_LABEL_WIDTH = 375;
    const int KEY_FIELD_WIDTH = 125;
    const int KEY_LABEL_MARGIN = 25;
    const int KEY_COLUMN_TOP = ROW_HEIGHT * 2;
    const int KEY_ROW_COUNT = 10;
    const int KEY_COLUMN_WIDTH = KEY_LABEL_WIDTH + KEY_LABEL_MARGIN + KEY_FIELD_WIDTH;
    const int KEY_COLUMN_HEIGHT = ROW_HEIGHT * KEY_ROW_COUNT + FRAME_MARGIN * 2;
    const int PAGER_BREAKPOINT = KEY_COLUMN_WIDTH * 2 + FRAME_MARGIN * 2;

    GuiElement* container;
    GuiElement* top_row;
    GuiPanel* rebinding_ui;
    GuiElement* bottom_row;

    GuiAutoLayout* rebinding_container;
    std::vector<GuiAutoLayout*> rebinding_columns;
    std::vector<GuiAutoLayout*> rebinding_rows;
    std::vector<GuiHotkeyBinder*> text_entries;
    std::vector<GuiLabel*> label_entries;
    GuiArrowButton* previous_page;
    GuiArrowButton* next_page;
    GuiOverlay* error_window;

    string category = "";
    int category_index = 1;
    std::vector<string> category_list;
    std::vector<std::pair<string, string>> hotkey_list;

    void setCategory(int cat);
    void saveHotkeys();
    void pageHotkeys(int direction);
public:
    HotkeyMenu();

    void onKey(sf::Event::KeyEvent key, int unicode);
};

#endif //HOTKEYMENU_H
