#include "hotkeyMenu.h"
#include <i18n.h>
#include <regex>
#include "init/config.h"
#include "engine.h"
#include "soundManager.h"
#include "main.h"

#include "gui/hotkeyBinder.h"
#include "gui/theme.h"
#include "gui/gui2_button.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrollcontainer.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"

HotkeyMenu::HotkeyMenu(OptionsMenu::ReturnTo return_to)
: return_to(return_to)
{
    new GuiOverlay(this, "", GuiTheme::getColor("background"));
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiledThemed("background.crosses");

    container = new GuiElement(this, "HOTKEY_CONFIG_CONTAINER");
    container
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)
        ->setMargins(FRAME_MARGIN * 0.5f)
        ->setAttribute("layout", "vertical");

    top_row = new GuiElement(container, "TOP_ROW_CONTAINER");
    top_row
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT);

    rebinding_ui = new GuiPanel(container, "REBINDING_UI_CONTAINER");
    rebinding_ui
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");
    rebinding_ui
        ->setAttribute("padding", "20");

    // Fixed column header row (not scrollable).
    auto* header_row = new GuiElement(rebinding_ui, "HOTKEY_HEADER");
    header_row
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT * 0.5f)
        ->setAttribute("layout", "horizontal");

    (new GuiLabel(header_row, "HOTKEY_HEADER_SPACER", "", 18.0f))
        ->setSize(KEY_LABEL_WIDTH, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
    (new GuiLabel(header_row, "HOTKEY_HEADER_KB", tr("Keyboard"), 18.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
    (new GuiLabel(header_row, "HOTKEY_HEADER_JS", tr("Joystick"), 18.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
    (new GuiLabel(header_row, "HOTKEY_HEADER_MS", tr("Mouse"), 18.0f))
        ->setAlignment(sp::Alignment::CenterLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);

    info_container = new GuiElement(container, "INFO_CONTAINER_CONTAINER");
    info_container
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT * 3.0f);

    bottom_row = new GuiElement(container, "BOTTOM_ROW_CONTAINER");
    bottom_row
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT);

    // Single-column layout
    // Top: Title and category navigation

    // Title label
    (new GuiLabel(top_row, "CONFIGURE_CONTROLS_LABEL", tr("Configure controls"), 30.0f))
        ->addBackground()
        ->setSize(350.0f, GuiElement::GuiSizeMax);

    // Category selector
    // Get a list of hotkey categories
    category_list = sp::io::Keybinding::getCategories();
    auto* category_selector = new GuiSelector(top_row, "Category",
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

    // Middle: Rebinding UI frame
    scroll_container = new GuiScrollContainer(rebinding_ui, "HOTKEY_CONTAINER");
    scroll_container
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");

    // Show category 0 ("General")
    HotkeyMenu::setCategory(0);
    category_selector->setSelectionIndex(0);

    // Bottom: Menu navigation

    // Back button to return to the Options menu
    (new GuiScrollText(info_container, "INFO_LABEL",
        tr("Left click: Assign input. Middle click: Add input. Right click: Remove last input.\nSupported inputs: Keyboard keys, joystick buttons and axes, mouse buttons (except left mouse button).")
    ))
        ->setPosition(10.0f, 0.0f, sp::Alignment::TopCenter)
        ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT * 3)
        ->setAttribute("margin", "0, 0, 20, 0");

    (new GuiButton(bottom_row, "BACK", tr("button", "Back"),
        [this, return_to]()
        {
            // Close this menu, stop the music, and return to the main menu.
            destroy();
            soundManager->stopMusic();
            returnToOptionMenu(return_to);
        }
    ))
        ->setPosition(0.0f, 0.0f, sp::Alignment::BottomLeft)
        ->setSize(150.0f, GuiElement::GuiSizeMax);

    // Reset keybinds confirmation
    reset_label = new GuiLabel(bottom_row, "RESET_LABEL", tr("Bindings reset to defaults"), 30.0f);
    reset_label
        ->setAlignment(sp::Alignment::CenterRight)
        ->setPosition(0.0f, -50.0f, sp::Alignment::BottomRight)
        ->setSize(100.0f, 50.0f)
        ->hide();

    // Reset keybinds button
    (new GuiButton(bottom_row, "RESET", tr("button", "Reset"),
        [this]()
        {
            reset_label->setVisible(true);
            reset_label_timer = RESET_LABEL_TIMEOUT;

            // Iterate through all bindings and reset to defaults.
            for (auto category : sp::io::Keybinding::getCategories())
            {
                for (auto item : sp::io::Keybinding::listAllByCategory(category))
                {
                    // Clear current binding.
                    item->clearKeys();

                    // Get the default binding, if any, and set it as the item's new
                    // binding.
                    std::vector<string> default_bindings = item->getDefaultBindings();
                    for (auto binding : default_bindings) item->addKey(binding);
                }
            }
        }
    ))
        ->setPosition(0.0f, 0.0f, sp::Alignment::BottomRight)
        ->setSize(150.0f, GuiElement::GuiSizeMax);
}

void HotkeyMenu::update(float delta)
{
    // Tick countdown to hiding the reset indicator.
    if (reset_label->isVisible())
    {
        reset_label_timer -= delta;
        reset_label->setVisible(reset_label_timer > 0.0f);
    }

    // Return to the options menu on Esc/Home bind, but not while rebinding.
    if (keys.escape.getDown() && !GuiHotkeyBinder::isAnyRebinding())
    {
        destroy();
        returnToOptionMenu(return_to);
    }
}

// Display a list of hotkeys to bind from the given hotkey category.
void HotkeyMenu::setCategory(int cat)
{
    // Remove any previous category's hotkey entries.
    for (GuiHotkeyBinder* text : text_entries) text->destroy();
    text_entries.clear();
    for (auto label : label_entries) label->destroy();
    label_entries.clear();
    for (auto row : rebinding_rows) row->destroy();
    rebinding_rows.clear();

    // Reset scroll to top when switching categories.
    scroll_container->scrollToOffset(0.0f);

    // Get the chosen category
    category_index = cat;
    category = category_list[cat];

    // Get all hotkeys in this category.
    hotkey_list = sp::io::Keybinding::listAllByCategory(category);

    const sp::io::Keybinding::Type joystick_type = sp::io::Keybinding::Type::Joystick | sp::io::Keybinding::Type::Controller;

    // Begin rendering hotkey rebinding fields for this category.
    for (auto item : hotkey_list)
    {
        // Add a rebinding row to the scroll container.
        rebinding_rows.push_back(new GuiElement(scroll_container, ""));
        rebinding_rows.back()
            ->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)
            ->setAttribute("layout", "horizontal");

        // Add a label to the current row.
        label_entries.push_back(new GuiLabel(rebinding_rows.back(), "HOTKEY_LABEL_" + item->getName(), item->getLabel(), 30.0f));
        label_entries.back()
            ->setAlignment(sp::Alignment::CenterRight)
            ->setSize(KEY_LABEL_WIDTH, GuiElement::GuiSizeMax)
            ->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);

        // Keyboard-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_KB_" + item->getName(), item, sp::io::Keybinding::Type::Keyboard, sp::io::Keybinding::Type::Keyboard));
        text_entries.back()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);

        // Joystick/controller-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_JS_" + item->getName(), item, joystick_type, joystick_type));
        text_entries.back()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);

        // Mouse-only binder.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_rows.back(), "HOTKEY_MS_" + item->getName(), item, sp::io::Keybinding::Type::Mouse, sp::io::Keybinding::Type::Mouse));
        text_entries.back()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0.0f, 0.0f, KEY_BINDER_MARGIN, 0.0f);
    }
}

