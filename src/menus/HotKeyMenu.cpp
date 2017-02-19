#include "engine.h"
#include "HotKeyMenu.h"
#include "main.h"
#include "preferenceManager.h"
#include "gui/gui2_element.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_scrollbar.h"

HotKeyMenu::HotKeyMenu()
{
    P<WindowManager> windowManager = engine->getObject("windowManager");

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Left column, manual layout. Draw first element at 50px from top.
    int top = 50;
    (new GuiLabel(this, "HOTKEY_OPTIONS_LABEL", "HOTKEYS", 30))->addBackground()->setPosition(50, top, ATopLeft)->setSize(500, 50);

    // Category selector.
    top += 50;
    CategoryList = hotkeys.getCategories();
    (new GuiSelector(this, "Category", [this](int index, string value)
    {
        HotKeyMenu::setCategory(index);
    }))->setOptions(CategoryList)->setSelectionIndex(cat_index)->setPosition(50, top, ATopLeft)->setSize(500, 50);

    // frame with keys
    top += 60;
    frame = new GuiPanel(this, "HELP_FRAME");
    frame->setPosition(50, top, ATopLeft)->setSize(600, 600);

    Cat_label = new GuiLabel(frame, "Category_Label", category, 30);
    Cat_label->addBackground()->setPosition(50, 10, ATopLeft)->setSize(500, 50);

    // initial category listing
    HotKeyMenu::setCategory(1);

    // Bottom GUI.
    // Back button.
    (new GuiButton(this, "BACK", "Back", [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToOptionMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    // Update Hotkey Values
    (new GuiButton(this, "UPDATE", "Set Hotkeys", [this]()
    {
        HotKeyMenu::updateHotKeys();
    }))->setPosition(400, -50, ABottomLeft)->setSize(300, 50);
}

void HotKeyMenu::onKey(sf::Event::KeyEvent key, int unicode)
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

void HotKeyMenu::setCategory(int cat)
{
    // remove old entries
    for (GuiTextEntry* text : text_entries){
        text->destroy();
    }
    text_entries.clear();
    for (GuiLabel* label : label_entries){
        label->destroy();
    }
    label_entries.clear();

    // reset help frame size
    int frame_width = 600;
    frame->setSize(frame_width, 600);

    // get chosen category
    cat_index = cat;
    category = CategoryList[cat];

    int top = 70;

    HotKeyList = hotkeys.listAllHotkeysByCategory(category);

    // begin filling of Hotkey listing for category
    Cat_label->setText(category);
    int left = 50;
    for (std::pair<string,string> item : HotKeyList) {

        label_entries.push_back(new GuiLabel(frame, "NAME_LABEL", item.first.append(" = "), 30));
        label_entries.back()->setPosition(left, top, ATopLeft)->setSize(300, 50);

        text_entries.push_back(new GuiTextEntry(frame, "HotKey_Entry", item.second));
        text_entries.back()->setTextSize(30)->setPosition(left+300, top, ATopLeft)->setSize(200, 50);
        top += 50;

        if (top>550){
            left = left + 550;
            top = 60;
            frame_width = frame_width + 600;
            frame->setSize(frame_width, 600);
        }
    }
}

void HotKeyMenu::updateHotKeys()
{
    int i = 0;
    std::string text = "";
    bool hotkey_exists = false;

    // read in all TextEntry values and update hotkeys
    for (std::pair<string,string> item : HotKeyList) {

        text = text_entries[i]->getText();
        hotkey_exists = hotkeys.setHotKey(category, item, text);

        if (!hotkey_exists){
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
