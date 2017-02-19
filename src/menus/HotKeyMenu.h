#ifndef EMPTYEPSILON_HOTKEYMENU_H
#define EMPTYEPSILON_HOTKEYMENU_H

#include <gui/gui2_entrylist.h>
#include "gui/gui2_canvas.h"
#include "gui/gui2_scrollbar.h"

class GuiOverlay;
class GuiSlider;
class GuiLabel;
class GuiCanvas;
class GuiPanel;
class GuiScrollText;
class GuiTextEntry;

class HotKeyMenu : public GuiCanvas
{
private:
    std::vector<GuiTextEntry*> text_entries;
    std::vector<GuiLabel*> label_entries;
    GuiLabel* Cat_label;
    GuiOverlay* error_window;

    string category = "";
    int    cat_index = 1;
    std::vector<string> CategoryList;
    std::vector<std::pair<string, string>> HotKeyList;

    void setCategory(int cat);
    void updateHotKeys();
public:
    HotKeyMenu();
    GuiPanel* frame;

    void onKey(sf::Event::KeyEvent key, int unicode);
};

#endif //EMPTYEPSILON_HOTKEYMENU_H
