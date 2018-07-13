#include "engine.h"
#include "hotkeyMenu.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

HotkeyMenu::HotkeyMenu()
{
	P<WindowManager> windowManager = engine->getObject("windowManager");

	new GuiOverlay(this, "", colorConfig.background);
	(new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosess");

	// Left column, manual layout. Draw first element at 50px from top.
	int top = 50;
	(new GuiLabel(this, "HOTKEY_OPTIONS_LABEL", "Hotkeys", 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(500, 50);

	// Category selector.
	top += 50;
	category_list = hotkeys.getCategories();
	(new GuiSelector(this, "CATEGORY", [this](int index, string value)
	{
		HotkeyMenu::setCategory(index);
	}))->setOptions(category_list)->setSelectionIndex(cat_index)->setPosition(50, top, ATopLeft)->setSize(500, 50);

	// frame with keys
	top += 60;
	frame = new GuiPanel(this, "HELP_FRAME");
	frame->setPosition(50, top, ATopLeft)->setSize(600, 600);

	cat_label = new GuiLabel(frame, "CATEGORY_LABEL", category, 30);
	cat_label->addBackground()->setPosition(50, 10, ATopLeft)->setSize(500, 50);

	// initial category listing
	HotkeyMenu::setCategory(1);

	// Bottom GUI.
	// Back button.
	(new GuiButton(this, "BACK", "Back", [this]()
	{
		// Close this menu, stop the music, and return to the main menu.
		destroy();
		soundManager->stopMusic();
		returnToOptionMenu();
	}))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

	// Update hotkey values
	(new GuiButton(this, "UPDATE", "Set hotkeys", [this]()
	{
		HotkeyMenu::updateHotkeys();
	}))->setPosition(400, -50, ABottomLeft)->setSize(300, 50);
}

void HotkeyMenu::onKey(sf::Event::KeyEvent key, int unicode)
{
	switch(key.code)
	{
		//TODO: This is more generic code and is duplicated.
		case sf::Keyboard::Escape:
		case sf::Keyboard::Home:
			destroy();
			returnToOptionMenu();
			break;
		default:
			break;
	}
}

void HotkeyMenu::setCategory(int cat)
{
	// remove old entries
	for (GuiTextEntry* text : text_entries)
	{
		text->destroy();
	}
	text_entries.clear();
	for (GuiLabel* label : label_entries)
	{
		label->destroy();
	}
	label_entries.clear();

	// reset help frame size
	int frame_width = 600;
	frame->setSize(frame_width, 600);

	// get chosen category
	cat_index = cat;
	category = category_list[cat];

	int top = 70;

	hotkey_list = hotkeys.listAllHotkeysByCategory(category);

	// begin filling of Hotkey listing for category
	cat_label->setText(category);
	int left = 50;
	int i = 0;
	for (std::pair<string,string> item : hotkey_list)
	{
		label_entries.push_back(new GuiLabel(frame, "NAME_LABEL_" + string(i), item.first.append(" = "), 30));
		label_entries.back()->setPosition(left, top, ATopLeft)->setSize(300, 50);

		text_entries.push_back(new GuiTextEntry(frame, "HOTKEY_ENTRY_" + string(i), item.second));
		text_entries.back().setTextSize(30)->setPosition(left+300, top, ATopLeft)->setSize(200, 50);
		top += 50;
		i++;

		if (top > 550)
		{
			left += 550;
			top = 60;
			frame_width += 600;
			frame->setSize(frame_width, 600);
		}
	}
}

void HotkeyMenu::updateHotkeys()
{
	int i = 0;
	std::string text = "";
	bool hotkey_exists = false;

	if (category == "basic")
	{
		error_window = new GuiOverlay(this, "KEY_ERROR_OVERLAY", sf::Color::Black);
		error_window->setPosition(0, -100, ACenter)->setSize(500, 200)->setVisible(true);
		(new GuiLabel(error_window, "ERROR_LABEL", "BASIC hotkeys shall not be changed", 30))->setPosition(0, 50, ATopCenter)->setSize(300, 50);
		(new GuiButton(error_window, "ERROR_OK", "OK", [this]()
		{
			// Close this window
			error_window->destroy();
		}))->setPosition(0, -10, ABottomCenter)->setSize(200, 50);
		return;
	}

	// Read in all TextEntry values and update hotkeys
	for (std::pair<string,string> item : hotkey_list)
	{
		text = text_entries[i].getText();
		hotkey_exists = hotkey.setHotkey(category, item, text);

		if (!hotkey_exists)
		{
			text_entries[i]->setText("");
			error_window = new GuiOverlay(this, "KEY_ERROR_OVERLAY", sf::Color::Black);
			error_window->setPosition(0, -100, ACenter)->setSize(500, 200)->setVisible(true);
			(new GuiLabel(error_window, "ERROR_LABEL", text.append(" -> this sfml key does not exist"), 30))->setPosition(0, 50, ATopCenter)->setSize(300, 50);
			(new GuiButton(error_window, "ERROR_OK", "OK", [this]()
			{
				// Close this window
				error_window->destroy();
			}))->setPosition(0, -10, ABottomCenter)->setSize(200, 50);
			return;
		}
		i++;
	}
}
