#ifndef EMPTYEPSILON_HOTKEYMENU_H_
#define EMPTYEPSILON_HOTKEYMENU_H_

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

class HotkeyMenu : public GuiCanvas
{
private:
	std::vector<GuiTextEntry*> text_entries;
	std::vector<GuiLabel*> label_entries;
	GuiLabel* cat_label;
	GuiOverlay* error_window;

	string category = "";
	int cat_index = 1;
	std::vector<string> category_list;
	std::vector<std::pair<string, string>> hotkey_list;

	void setCategory(int cat);
	void updateHotkeys();
public:
	HotkeyMenu();
	GuiPanel* frame;

	void onKey(sf::Event::KeyEvent key, int unicode);
};

#endif /* EMPTYEPSILON_HOTKEYMENU_H_ */
