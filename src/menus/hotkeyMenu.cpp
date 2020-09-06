#include <i18n.h>
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
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Left column, manual layout. Draw first element at 50px from top.
    (new GuiLabel(this, "HOTKEY_OPTIONS_LABEL", tr("Hotkey Configuration"), 30))->addBackground()->setPosition(50, 50, ATopLeft)->setSize(300, 50);

    // Category selector
    category_list = hotkeys.getCategories();
    (new GuiSelector(this, "Category", [this](int index, string value)
    {
        HotkeyMenu::setCategory(index);
    }))->setOptions(category_list)->setSelectionIndex(category_index)->setPosition(0, 50, ATopCenter)->setSize(300, 50);

    // Page selector
    previous_page = new GuiButton(this, "PAGE_LEFT", "<-", [this]()
    {
        HotkeyMenu::pageHotkeys(1);
    });
    previous_page->setPosition(-100, 50, ATopRight)->setSize(50, 50)->disable();
    next_page = new GuiButton(this, "PAGE_RIGHT", "->", [this]()
    {
        HotkeyMenu::pageHotkeys(-1);
    });
    next_page->setPosition(-50, 50, ATopRight)->setSize(50, 50)->disable();

    // frame with keys
    frame = new GuiPanel(this, "HELP_FRAME");
    frame->setPosition(50, FRAME_TOP, ATopLeft)->setSize(600, FRAME_HEIGHT);

    // TODO: This label is redundant with the category selector
    // category_label = new GuiLabel(frame, "Category_Label", category, 30);
    // category_label->addBackground()->setPosition(50, 10, ATopLeft)->setSize(500, 50);

    // initial category listing
    HotkeyMenu::setCategory(1);

    // Bottom GUI.
    // Back button.
    (new GuiButton(this, "BACK", tr("options", "Back"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToOptionMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(150, 50);

    // Update Hotkey Values
    (new GuiButton(this, "UPDATE", tr("options", "Save"), [this]()
    {
        HotkeyMenu::updateHotKeys();
    }))->setPosition(200, -50, ABottomLeft)->setSize(150, 50);
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
    for (GuiTextEntry* text : text_entries){
        text->destroy();
    }
    text_entries.clear();
    for (GuiLabel* label : label_entries){
        label->destroy();
    }
    label_entries.clear();

    // reset hotkey frame size and position
    int frame_width = FRAME_INITIAL_WIDTH;
    frame->setPosition(50, FRAME_TOP, ATopLeft)->setSize(frame_width, FRAME_HEIGHT);

    // get chosen category
    category_index = cat;
    category = category_list[cat];

    int top = FRAME_PADDING;
    int left = FRAME_PADDING;

    hotkey_list = hotkeys.listAllHotkeysByCategory(category);

    // TODO: This label is redundant with the category selector
    // category_label->setText(category);

    // begin filling of Hotkey listing for category
    for (std::pair<string,string> item : hotkey_list) {

        label_entries.push_back(new GuiLabel(frame, "NAME_LABEL", item.first.append(" = "), 30));
        label_entries.back()->setAlignment(ACenterRight)->setPosition(left, top, ATopLeft)->setSize(400, 50);

        text_entries.push_back(new GuiTextEntry(frame, "HotKey_Entry", item.second));
        text_entries.back()->setTextSize(30)->setPosition(left + 400, top, ATopLeft)->setSize(100, 50);
        top += 50;

        // This keeps adding columns even if they don't fit on the screen
        if (top > 650) {
            left = left + 550;
            top = FRAME_PADDING;
            frame_width = frame_width + 550;
            frame->setSize(frame_width, FRAME_HEIGHT);
        }

        // Enable pagination buttons if pagination is necessary
        // TODO: Detect viewport width instead of hardcoding breakpoint at 1200
        if (frame_width >= 1200) {
            previous_page->enable();
            next_page->enable();
        } else {
            previous_page->disable();
            next_page->disable();
        }
    }
}

void HotkeyMenu::updateHotKeys()
{
    int i = 0;
    std::string text = "";
    bool hotkey_exists = false;

    if (category == "basic") {
        error_window = new GuiOverlay(this, "KEY_ERROR_OVERLAY", sf::Color::Black);
        error_window->setPosition(0, -100, ACenter)->setSize(500, 200)->setVisible(true);
        // TODO: If basic hotkeys can't be modified, why are they editabel in this menu?
        (new GuiLabel(error_window, "ERROR_LABEL", "Basic hotkeys cannot be changed", 30))->setPosition(0, 50, ATopCenter)->setSize(300, 50);
        (new GuiButton(error_window, "ERROR_OK", "OK", [this]()
        {
            // Close this window
            error_window->destroy();
        }))->setPosition(0, -10, ABottomCenter)->setSize(200, 50);
        return;
    }

    // read in all TextEntry values and update hotkeys
    for (std::pair<string,string> item : hotkey_list) {

        text = text_entries[i]->getText();
        hotkey_exists = hotkeys.setHotKey(category, item, text);

        if (!hotkey_exists) {
            text_entries[i]->setText("");
            error_window = new GuiOverlay(this, "KEY_ERROR_OVERLAY", sf::Color::Black);
            error_window->setPosition(0, -100, ACenter)->setSize(500, 200)->setVisible(true);
            // Keys without equivalent SFML codes can't be accepted.
            (new GuiLabel(error_window, "ERROR_LABEL", text.append(" -> this key is not supported"), 30))->setPosition(0, 50, ATopCenter)->setSize(300, 50);
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

void HotkeyMenu::pageHotkeys(int direction)
{
    sf::Vector2f frame_position = frame->getPositionOffset();
    sf::Vector2f frame_size = frame->getSize();

    if (frame_size.x < 1200)
    {
        return;
    }

    // Move the frame left if direction is negative,
    // right if it's positive.
    int new_offset = frame_position.x + 550 * direction;

    if (new_offset >= 50)
    {
        // Don't let the frame move right if its left edge is on screen.
        frame->setPosition(50, 100, ATopLeft);
    }
    else if (new_offset > -frame_size.x + 600)
    {
        // Move the frame left only if its right edge is not on screen.
        frame->setPosition(new_offset, 100, ATopLeft);
    }
}