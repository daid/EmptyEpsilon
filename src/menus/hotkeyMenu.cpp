#include <i18n.h>
#include "engine.h"
#include "hotkeyMenu.h"

#include "gui/hotkeyBinder.h"
#include "gui/gui2_autolayout.h"
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

    // TODO: Figure out how to make this an AutoLayout.
    container = new GuiElement(this, "HOTKEY_CONFIG_CONTAINER");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft)->setMargins(FRAME_MARGIN);

    top_row = new GuiElement(container, "TOP_ROW_CONTAINER");
    top_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, ATopLeft);

    rebinding_ui = new GuiPanel(container, "REBINDING_UI_CONTAINER");
    rebinding_ui->setSize(GuiElement::GuiSizeMax, KEY_COLUMN_HEIGHT)->setPosition(0, KEY_COLUMN_TOP, ATopLeft);

    bottom_row = new GuiElement(container, "BOTTOM_ROW_CONTAINER");
    bottom_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, ABottomLeft);

    // Single-column layout
    // Top: Title and category navigation

    // Title label
    (new GuiLabel(top_row, "CONFIGURE_KEYBOARD_LABEL", tr("Configure Keyboard"), 30))->addBackground()->setPosition(0, 0, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    // Category selector
    // Get a list of hotkey categories
    category_list = hotkeys.getCategories();
    (new GuiSelector(top_row, "Category", [this](int index, string value)
    {
        HotkeyMenu::setCategory(index);
    }))->setOptions(category_list)->setSelectionIndex(category_index)->setSize(300, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopCenter);

    // Page navigation
    previous_page = new GuiArrowButton(container, "PAGE_LEFT", 0, [this]()
    {
        HotkeyMenu::pageHotkeys(1);
    });
    previous_page->setPosition(0, 0, ACenterLeft)->setSize(GuiElement::GuiSizeMatchHeight, ROW_HEIGHT)->disable();

    next_page = new GuiArrowButton(container, "PAGE_RIGHT", 180, [this]()
    {
        HotkeyMenu::pageHotkeys(-1);
    });
    next_page->setPosition(0, 0, ACenterRight)->setSize(GuiElement::GuiSizeMatchHeight, ROW_HEIGHT)->disable();

    // Middle: Rebinding UI frame
    rebinding_container = new GuiAutoLayout(rebinding_ui, "HOTKEY_CONFIG_CONTAINER", GuiAutoLayout::ELayoutMode::LayoutHorizontalLeftToRight);
    rebinding_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft)->setMargins(FRAME_MARGIN);

    // Show category 1 ("General")
    HotkeyMenu::setCategory(1);

    // Bottom: Menu navigation
    // Back button to return to the Options menu
    (new GuiButton(bottom_row, "BACK", tr("options", "BACK"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToOptionMenu();
    }))->setPosition(0, 0, ABottomLeft)->setSize(150, GuiElement::GuiSizeMax);

    // Save hotkey values
    (new GuiButton(bottom_row, "SAVE", tr("options", "Save"), [this]()
    {
        HotkeyMenu::saveHotkeys();
    }))->setPosition(150, 0, ABottomLeft)->setSize(150, GuiElement::GuiSizeMax);
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

// Display a list of hotkeys to bind from the given hotkey category.
void HotkeyMenu::setCategory(int cat)
{
    // Remove any previous category's hotkey entries.
    for (GuiHotkeyBinder* text : text_entries)
    {
        text->destroy();
    }
    text_entries.clear();

    for (GuiLabel* label : label_entries)
    {
        label->destroy();
    }
    label_entries.clear();

    for (GuiAutoLayout* row : rebinding_rows)
    {
        row->destroy();
    }
    rebinding_rows.clear();

    for (GuiAutoLayout* column : rebinding_columns)
    {
        column->destroy();
    }
    rebinding_columns.clear();

    // Reset the hotkey frame size and position
    int rebinding_ui_width = KEY_COLUMN_WIDTH;
    rebinding_ui->setPosition(0, KEY_COLUMN_TOP, ATopLeft)->setSize(KEY_COLUMN_WIDTH + FRAME_MARGIN, ROW_HEIGHT * (KEY_ROW_COUNT + 2));

    // Get the chosen category
    category_index = cat;
    category = category_list[cat];

    // Initialize column row count so we can split columns.
    int column_row_count = 0;

    // Get all hotkeys in this category.
    hotkey_list = hotkeys.listAllHotkeysByCategory(category);

    // Begin rendering hotkey rebinding fields for this category.
    for (std::pair<string, string> item : hotkey_list)
    {
        // If we've filled a column, or don't have any rows yet, make a new column.
        if (rebinding_rows.size() == 0 || column_row_count >= KEY_ROW_COUNT)
        {
            column_row_count = 0;
            rebinding_columns.push_back(new GuiAutoLayout(rebinding_container, "", GuiAutoLayout::ELayoutMode::LayoutVerticalTopToBottom));
            rebinding_columns.back()->setSize(KEY_COLUMN_WIDTH, KEY_COLUMN_HEIGHT)->setMargins(0, 50);
        }

        // Add a rebinding row to the current column.
        column_row_count += 1;
        rebinding_rows.push_back(new GuiAutoLayout(rebinding_columns.back(), "", GuiAutoLayout::ELayoutMode::LayoutHorizontalLeftToRight));
        rebinding_rows.back()->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT);

        // Add a label to the current row.
        label_entries.push_back(new GuiLabel(rebinding_rows.back(), "HOTKEY_LABEL_" + item.first, item.first, 30));
        label_entries.back()->setAlignment(ACenterRight)->setSize(KEY_LABEL_WIDTH, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN / 2, 0);

        // Add a hotkey rebinding field to the current row.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_VALUE_" + item.first, item.second));
        text_entries.back()->setTextSize(30)->setSize(KEY_FIELD_WIDTH, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN / 2, 0);
    }

    // Resize the rendering UI panel based on the number of columns.
    rebinding_ui_width = KEY_COLUMN_WIDTH * rebinding_columns.size() + FRAME_MARGIN;
    rebinding_ui->setSize(rebinding_ui_width, KEY_COLUMN_HEIGHT);

    // Enable pagination buttons if pagination is necessary.
    // TODO: Detect viewport width instead of hardcoding breakpoint at
    // two columns
    if (rebinding_columns.size() > 2)
    {
        previous_page->enable();
        next_page->enable();
    } else {
        previous_page->disable();
        next_page->disable();
    }
}

void HotkeyMenu::saveHotkeys()
{
    // Save hotkeys
    int i = 0;
    std::string text = "";
    bool hotkey_exists = false;

    if (category == "basic")
    {
        error_window = new GuiOverlay(container, "KEY_ERROR_OVERLAY", sf::Color::Black);
        error_window->setSize(500, 200)->setPosition(0, -100, ACenter)->setVisible(true);

        // TODO: If basic hotkeys can't be modified, why are they editable in this menu?
        (new GuiLabel(error_window, "ERROR_LABEL", "Basic hotkeys cannot be changed", 30))->setSize(300, 50)->setPosition(0, 50, ATopCenter);
        (new GuiButton(error_window, "ERROR_OK", "OK", [this]()
        {
            // Close this window
            error_window->destroy();
        }))->setSize(200, 50)->setPosition(0, -10, ABottomCenter);

        return;
    }

    // Read in all TextEntry values and update hotkeys
    for (std::pair<string,string> item : hotkey_list)
    {
        text = text_entries[i]->getText();
        hotkey_exists = hotkeys.setHotkey(category, item, text);

        if (!hotkey_exists)
        {
            // Keys without equivalent SFML codes can't be accepted.
            // Blank the corresponding key entry field.
            text_entries[i]->setText("");

            // Throw an error modal.
            error_window = new GuiOverlay(container, "KEY_ERROR_OVERLAY", sf::Color::Black);
            error_window->setSize(500, 200)->setPosition(0, -100, ACenter)->setVisible(true);

            (new GuiLabel(error_window, "ERROR_LABEL", text.append(": This key can't be used"), 30))->setSize(300, 50)->setPosition(0, 50, ATopCenter);
            (new GuiButton(error_window, "ERROR_OK", "OK", [this]()
            {
                // Close this modal
                error_window->destroy();
            }))->setSize(200, 50)->setPosition(0, -10, ABottomCenter);

            // TODO: This return stops at the first non-extant hotkey.
            // Others aren't flagged or removed. It should probably keep going.
            return;
        }
        i++;
    }
}

void HotkeyMenu::pageHotkeys(int direction)
{
    sf::Vector2f frame_position = rebinding_ui->getPositionOffset();
    sf::Vector2f frame_size = rebinding_ui->getSize();

    if (frame_size.x < KEY_COLUMN_WIDTH * 2)
    {
        return;
    }

    // Move the frame left if the direction is negative, right if it's positive
    int new_offset = frame_position.x + KEY_COLUMN_WIDTH * direction;

    if (new_offset >= 0)
    {
        // Don't let the frame move right if its left edge is on screen.
        rebinding_ui->setPosition(0, KEY_COLUMN_TOP, ATopLeft);
    }
    else if (new_offset > -frame_size.x + KEY_COLUMN_WIDTH + FRAME_MARGIN)
    {
        // Move the frame left only if its right edge is not on screen.
        rebinding_ui->setPosition(new_offset, KEY_COLUMN_TOP, ATopLeft);
    }
}
