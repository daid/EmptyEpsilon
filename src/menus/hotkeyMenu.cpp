#include <i18n.h>
#include "engine.h"
#include "hotkeyMenu.h"
#include <regex>
#include "soundManager.h"

#include "gui/hotkeyBinder.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

HotkeyMenu::HotkeyMenu()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // TODO: Figure out how to make this an AutoLayout.
    container = new GuiElement(this, "HOTKEY_CONFIG_CONTAINER");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft)->setMargins(FRAME_MARGIN);

    top_row = new GuiElement(container, "TOP_ROW_CONTAINER");
    top_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::TopLeft);

    rebinding_ui = new GuiPanel(container, "REBINDING_UI_CONTAINER");
    rebinding_ui->setSize(GuiElement::GuiSizeMax, KEY_COLUMN_HEIGHT)->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft);

    bottom_row = new GuiElement(container, "BOTTOM_ROW_CONTAINER");
    bottom_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::BottomLeft);

    // Single-column layout
    // Top: Title and category navigation

    // Title label
    (new GuiLabel(top_row, "CONFIGURE_KEYBOARD_LABEL", tr("Configure Keyboard"), 30))->addBackground()->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(300, GuiElement::GuiSizeMax);

    // Category selector
    // Get a list of hotkey categories
    category_list = sp::io::Keybinding::getCategories();
    (new GuiSelector(top_row, "Category", [this](int index, string value)
    {
        HotkeyMenu::setCategory(index);
    }))->setOptions(category_list)->setSelectionIndex(category_index)->setSize(300, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopCenter);

    // Page navigation
    previous_page = new GuiArrowButton(container, "PAGE_LEFT", 0, [this]()
    {
        HotkeyMenu::pageHotkeys(1);
    });
    previous_page->setPosition(0, 0, sp::Alignment::CenterLeft)->setSize(GuiElement::GuiSizeMatchHeight, ROW_HEIGHT)->disable();

    next_page = new GuiArrowButton(container, "PAGE_RIGHT", 180, [this]()
    {
        HotkeyMenu::pageHotkeys(-1);
    });
    next_page->setPosition(0, 0, sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMatchHeight, ROW_HEIGHT)->disable();

    // Middle: Rebinding UI frame
    rebinding_container = new GuiElement(rebinding_ui, "HOTKEY_CONFIG_CONTAINER");
    rebinding_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft)->setMargins(FRAME_MARGIN)->setAttribute("layout", "horizontal");

    // Show category 1 ("General")
    HotkeyMenu::setCategory(1);

    // Bottom: Menu navigation
    // Back button to return to the Options menu
    (new GuiButton(bottom_row, "BACK", tr("button", "Back"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        soundManager->stopMusic();
        returnToOptionMenu();
    }))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(150, GuiElement::GuiSizeMax);
}

void HotkeyMenu::update(float delta)
{
    if (keys.escape.getDown())
    {
        destroy();
        returnToOptionMenu();
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

    for (auto label : label_entries)
    {
        label->destroy();
    }
    label_entries.clear();

    for (auto row : rebinding_rows)
    {
        row->destroy();
    }
    rebinding_rows.clear();

    for (auto column : rebinding_columns)
    {
        column->destroy();
    }
    rebinding_columns.clear();

    // Reset the hotkey frame size and position
    int rebinding_ui_width = KEY_COLUMN_WIDTH;
    rebinding_ui->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft)->setSize(KEY_COLUMN_WIDTH + FRAME_MARGIN, ROW_HEIGHT * (KEY_ROW_COUNT + 2));

    // Get the chosen category
    category_index = cat;
    category = category_list[cat];

    // Initialize column row count so we can split columns.
    int column_row_count = 0;

    // Get all hotkeys in this category.
    hotkey_list = sp::io::Keybinding::listAllByCategory(category);

    // Begin rendering hotkey rebinding fields for this category.
    for (auto item : hotkey_list)
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
        rebinding_rows.push_back(new GuiElement(rebinding_columns.back(), ""));
        rebinding_rows.back()->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setAttribute("layout", "horizontal");

        // Add a label to the current row.
        label_entries.push_back(new GuiLabel(rebinding_rows.back(), "HOTKEY_LABEL_" + item->getName(), item->getLabel(), 30));
        label_entries.back()->setAlignment(sp::Alignment::CenterRight)->setSize(KEY_LABEL_WIDTH, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN / 2, 0);

        // Add a hotkey rebinding field to the current row.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_VALUE_" + item->getName(), item));
        text_entries.back()->setSize(KEY_FIELD_WIDTH, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN / 2, 0);
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

void HotkeyMenu::pageHotkeys(int direction)
{
    auto frame_position = rebinding_ui->getPositionOffset();
    auto frame_size = rebinding_ui->getSize();

    if (frame_size.x < KEY_COLUMN_WIDTH * 2)
    {
        return;
    }

    // Move the frame left if the direction is negative, right if it's positive
    int new_offset = frame_position.x + KEY_COLUMN_WIDTH * direction;

    if (new_offset >= 0)
    {
        // Don't let the frame move right if its left edge is on screen.
        rebinding_ui->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft);
    }
    else if (new_offset > -frame_size.x + KEY_COLUMN_WIDTH + FRAME_MARGIN)
    {
        // Move the frame left only if its right edge is not on screen.
        rebinding_ui->setPosition(new_offset, KEY_COLUMN_TOP, sp::Alignment::TopLeft);
    }
}
