#include <i18n.h>
#include "init/config.h"
#include "engine.h"
#include "hotkeyMenu.h"
#include <regex>
#include "soundManager.h"
#include "main.h"

#include "gui/hotkeyBinder.h"
#include "gui/theme.h"
#include "gui/gui2_arrowbutton.h"
#include "gui/gui2_button.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_togglebutton.h"

HotkeyMenu::HotkeyMenu(OptionsMenu::ReturnTo return_to)
: return_to(return_to)
{
    new GuiOverlay(this, "", GuiTheme::getColor("background"));
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiledThemed("background.crosses");

    container = new GuiElement(this, "HOTKEY_CONFIG_CONTAINER");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft)->setMargins(FRAME_MARGIN / 2.0f);

    top_row = new GuiElement(container, "TOP_ROW_CONTAINER");
    top_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::TopLeft);

    // Fixed column header row (shows KB/JS/Mouse labels, not scrollable).
    auto* header_row = new GuiElement(container, "HOTKEY_HEADER");
    header_row->setSize(KEY_COLUMN_WIDTH + FRAME_MARGIN, ROW_HEIGHT * 0.5f)->setPosition(0, ROW_HEIGHT * 1.5f, sp::Alignment::TopLeft);

    (new GuiElement(header_row, "HOTKEY_HEADER_SPACER"))
        ->setSize(KEY_LABEL_WIDTH + KEY_LABEL_MARGIN + KEY_BINDER_MARGIN, GuiElement::GuiSizeMax);
    (new GuiLabel(header_row, "HOTKEY_HEADER_KB", tr("Keyboard"), 30.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(KEY_BINDER_WIDTH + KEY_BINDER_MARGIN, GuiElement::GuiSizeMax);
    (new GuiLabel(header_row, "HOTKEY_HEADER_JS", tr("Joystick"), 30.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(KEY_BINDER_WIDTH + KEY_BINDER_MARGIN, GuiElement::GuiSizeMax);
    (new GuiLabel(header_row, "HOTKEY_HEADER_MS", tr("Mouse"), 30.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(KEY_BINDER_WIDTH + KEY_BINDER_MARGIN, GuiElement::GuiSizeMax);
    header_row->setAttribute("layout", "horizontal");

    rebinding_ui = new GuiPanel(container, "REBINDING_UI_CONTAINER");
    rebinding_ui->setSize(KEY_COLUMN_WIDTH + FRAME_MARGIN, KEY_COLUMN_HEIGHT)->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft);

    info_container = new GuiElement(container, "INFO_CONTAINER");
    info_container->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT * 2.0f)->setPosition(0, KEY_COLUMN_TOP + KEY_COLUMN_HEIGHT, sp::Alignment::TopLeft);

    bottom_row = new GuiElement(container, "BOTTOM_ROW_CONTAINER");
    bottom_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::BottomLeft);

    // Title label
    (new GuiLabel(top_row, "CONFIGURE_CONTROLS_LABEL", tr("Configure controls"), 30.0f))
        ->addBackground()
        ->setPosition(0, 0, sp::Alignment::TopLeft)
        ->setSize(300.0f, GuiElement::GuiSizeMax);

    // Category selector
    category_list = sp::io::Keybinding::getCategories();
    category_selector = new GuiSelector(top_row, "Category",
        [this](int index, string value)
        {
            HotkeyMenu::setCategory(index);
        }
    );
    category_selector
        ->setOptions(category_list)
        ->setSelectionIndex(category_index)
        ->setSize(300.0f, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopCenter);

    // Advanced binding dialog toggle
    dialog_mode_toggle = new GuiToggleButton(top_row, "DIALOG_MODE_TOGGLE", tr("hotkey_menu", "Advanced binding"),
        [this](bool active)
        {
            use_dialog_mode = active;
            info_container->setVisible(!active);
            setCategory(category_index);
        }
    );
    dialog_mode_toggle
        ->setValue(use_dialog_mode)
        ->setSize(300.0f, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopRight);

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
    rebinding_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft)->setAttribute("layout", "horizontal");

    // Info text for non-dialog mode
    (new GuiScrollText(info_container, "INFO_LABEL",
        tr("Left click: Assign input. Middle click: Add input. Right click: Remove last input.\nPossible inputs: Keyboard keys, joystick buttons and axes, mouse buttons and axes.")
    ))
        ->setTextSize(20.0f)
        ->setPosition(10.0f, 0.0f, sp::Alignment::TopCenter)
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT * 2.0f);

    // Bottom: Menu navigation

    // Back button to return to the Options menu
    (new GuiButton(bottom_row, "BACK", tr("button", "Back"),
        [this, return_to]()
        {
            destroy();
            soundManager->stopMusic();
            returnToOptionMenu(return_to);
        }
    ))
        ->setPosition(0, 0, sp::Alignment::BottomLeft)
        ->setSize(150.0f, GuiElement::GuiSizeMax);

    // Reset keybinds confirmation
    reset_label = new GuiLabel(bottom_row, "RESET_LABEL", tr("Bindings reset to defaults"), 30.0f);
    reset_label->addBackground()->setAlignment(sp::Alignment::Center)->setPosition(-150.0f, 0.0f, sp::Alignment::BottomRight)->setSize(300.0f, 50.0f)->hide();

    // Reset keybinds button
    (new GuiButton(bottom_row, "RESET", tr("button", "Reset"),
        [this]()
        {
            reset_label->setVisible(true);
            reset_label_timer.start(RESET_LABEL_TIMEOUT);

            // Iterate through all bindings and reset to defaults.
            for (auto category : sp::io::Keybinding::getCategories())
            {
                for (auto item : sp::io::Keybinding::listAllByCategory(category))
                {
                    item->clearKeys();

                    std::vector<string> default_bindings = item->getDefaultBindings();
                    for (auto binding : default_bindings) item->addKey(binding);

                    // Set each restored binding's interaction to the keybinding's
                    // default interaction for that input type.
                    for (int i = 0; item->getKeyType(i) != sp::io::Keybinding::Type::None; i++)
                        item->setInteraction(i, item->getDefaultInteraction(item->getKeyType(i)));
                }
            }
        }
    ))
        ->setPosition(0.0f, 0.0f, sp::Alignment::BottomRight)
        ->setSize(150.0f, GuiElement::GuiSizeMax);

    // Build the rebind dialog. Created last so it renders on top of everything.
    rebind_dialog = new GuiRebindDialog(this, "REBIND_DIALOG");

    // Dialog mode is on by default; hide the info text since the dialog
    // provides its own legend.
    info_container->hide();

    // Show category 0 ("General")
    HotkeyMenu::setCategory(0);
    category_selector->setSelectionIndex(0);
}

void HotkeyMenu::update(float delta)
{
    if (reset_label->isVisible() && reset_label_timer.isExpired())
        reset_label->hide();

    // Return to the options menu on Esc/Home bind, but not while rebinding or
    // while the rebind dialog is open.
    if (keys.escape.getDown()
        && !GuiHotkeyBinder::isAnyRebinding())
    {
        destroy();
        returnToOptionMenu(return_to);
    }

    // Change rebind category, but not while rebinding or while the rebind
    // dialog is open.
    if (keys.next_rebind_category.getDown()
        && !GuiHotkeyBinder::isAnyRebinding())
        setCategory(category_index + 1);
    if (keys.prev_rebind_category.getDown()
        && !GuiHotkeyBinder::isAnyRebinding())
        setCategory(category_index - 1);
    if (keys.toggle_rebind_dialog.getDown()
        && !GuiHotkeyBinder::isAnyRebinding())
    {
        dialog_mode_toggle->setValue(!dialog_mode_toggle->getValue());
        use_dialog_mode = dialog_mode_toggle->getValue();
        info_container->setVisible(!dialog_mode_toggle->getValue());
        setCategory(category_index);
    }
}

// Display a list of hotkeys to bind from the given hotkey category.
void HotkeyMenu::setCategory(int cat)
{
    // Loop category index if out of range.
    if (cat >= static_cast<int>(category_list.size())) cat = 0;
    if (cat < 0) cat = static_cast<int>(category_list.size()) - 1;

    // Close the dialog if it was open for a binder that is about to be destroyed.
    if (rebind_dialog) rebind_dialog->closeIfOpen();

    // Remove any previous category's hotkey entries.
    for (GuiHotkeyBinder* text : text_entries) text->destroy();
    text_entries.clear();
    for (auto label : label_entries) label->destroy();
    label_entries.clear();
    for (auto row : rebinding_rows) row->destroy();
    rebinding_rows.clear();
    for (auto column : rebinding_columns) column->destroy();
    rebinding_columns.clear();

    // Reset the hotkey frame size and position
    rebinding_ui->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft)->setSize(KEY_COLUMN_WIDTH + FRAME_MARGIN, KEY_COLUMN_HEIGHT);

    // Get the chosen category
    category_index = cat;
    category = category_list[cat];

    // Initialize column row count so we can split columns.
    int column_row_count = 0;

    // Get all hotkeys in this category.
    hotkey_list = sp::io::Keybinding::listAllByCategory(category);

    const sp::io::Keybinding::Type joystick_type = sp::io::Keybinding::Type::Joystick | sp::io::Keybinding::Type::Controller;

    // Begin rendering hotkey rebinding fields for this category.
    for (auto item : hotkey_list)
    {
        // If we've filled a column, or don't have any rows yet, make a new column.
        if (rebinding_rows.size() == 0 || column_row_count >= KEY_ROW_COUNT)
        {
            column_row_count = 0;
            rebinding_columns.push_back(new GuiElement(rebinding_container, ""));
            rebinding_columns.back()->setSize(KEY_COLUMN_WIDTH, KEY_COLUMN_HEIGHT)->setMargins(0, FRAME_MARGIN)->setAttribute("layout", "vertical");
        }

        // Add a rebinding row to the current column.
        column_row_count += 1;
        rebinding_rows.push_back(new GuiElement(rebinding_columns.back(), ""));
        rebinding_rows.back()->setSize(GuiElement::GuiSizeMax, KEY_ROW_HEIGHT)->setAttribute("layout", "horizontal");

        // Add a label to the current row.
        label_entries.push_back(new GuiLabel(rebinding_rows.back(), "HOTKEY_LABEL_" + item->getName(), item->getLabel(), 30.0f));
        label_entries.back()
            ->setWrapped()
            ->setAlignment(sp::Alignment::TopRight)
            ->setSize(KEY_LABEL_WIDTH, GuiElement::GuiSizeMax)
            ->setMargins(0.0f, 2.0f, KEY_LABEL_MARGIN, 0.0f);

        // Keyboard-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_KB_" + item->getName(), item,
            sp::io::Keybinding::Type::Keyboard, sp::io::Keybinding::Type::Keyboard));
        text_entries.back()
            ->setSize(KEY_BINDER_WIDTH, GuiElement::GuiSizeMax)
            ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
        if (use_dialog_mode && rebind_dialog)
            text_entries.back()->setDialog(rebind_dialog);

        // Joystick/controller-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_JS_" + item->getName(), item,
            joystick_type, joystick_type));
        text_entries.back()
            ->setSize(KEY_BINDER_WIDTH, GuiElement::GuiSizeMax)
            ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
        if (use_dialog_mode && rebind_dialog)
            text_entries.back()->setDialog(rebind_dialog);

        // Mouse-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_MS_" + item->getName(), item,
            sp::io::Keybinding::Type::Mouse, sp::io::Keybinding::Type::Mouse));
        text_entries.back()
            ->setSize(KEY_BINDER_WIDTH, GuiElement::GuiSizeMax)
            ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
        if (use_dialog_mode && rebind_dialog)
            text_entries.back()->setDialog(rebind_dialog);
    }

    // Resize the rendering UI panel based on the number of columns.
    float rebinding_ui_width = KEY_COLUMN_WIDTH * rebinding_columns.size() + FRAME_MARGIN;
    rebinding_ui->setSize(rebinding_ui_width, KEY_COLUMN_HEIGHT);

    // Enable pagination buttons if pagination is necessary.
    // TODO: Detect viewport width instead of hardcoding breakpoint at
    // two columns
    if (rebinding_columns.size() > 1)
    {
        previous_page->enable();
        next_page->enable();
    }
    else
    {
        previous_page->disable();
        next_page->disable();
    }

    category_selector->setSelectionIndex(cat);
}

void HotkeyMenu::pageHotkeys(int direction)
{
    auto frame_position = rebinding_ui->getPositionOffset();
    auto frame_size = rebinding_ui->getSize();

    if (frame_size.x <= KEY_COLUMN_WIDTH + FRAME_MARGIN) return;

    // Move the frame left if the direction is negative, right if it's positive
    float new_offset = frame_position.x + KEY_COLUMN_WIDTH * direction;

    // Don't let the frame move right if its left edge is on screen.
    // Move the frame left only if its right edge is not on screen.
    if (new_offset >= 0)
        rebinding_ui->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft);
    else if (new_offset >= -frame_size.x + KEY_COLUMN_WIDTH + FRAME_MARGIN)
        rebinding_ui->setPosition(new_offset, KEY_COLUMN_TOP, sp::Alignment::TopLeft);
}
