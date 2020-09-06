#ifndef HOTKEYMENU_H
#define HOTKEYMENU_H

#include "gui/gui2_entrylist.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_scrollbar.h"

class GuiOverlay;
class GuiSlider;
class GuiLabel;
class GuiCanvas;
class GuiPanel;
class GuiScrollText;
class GuiTextEntry;

class HotkeyMenu : public GuiCanvas
{
private:
    const int FRAME_TOP = 100;
    const int FRAME_HEIGHT = 700;
    const int FRAME_INITIAL_WIDTH = 550;
    const int FRAME_PADDING = 25;

    std::vector<GuiTextEntry*> text_entries;
    std::vector<GuiLabel*> label_entries;
    GuiButton* previous_page;
    GuiButton* next_page;
    GuiOverlay* error_window;

    string category = "";
    int category_index = 1;
    std::vector<string> category_list;
    std::vector<std::pair<string, string>> hotkey_list;

    void setCategory(int cat);
    void pageHotkeys(int direction);
    void updateHotKeys();
public:
    HotkeyMenu();
    GuiPanel* frame;

    void onKey(sf::Event::KeyEvent key, int unicode);
};

#endif //HOTKEYMENU_H
