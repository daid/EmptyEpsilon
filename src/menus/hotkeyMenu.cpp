#include <i18n.h>
#include "engine.h"
#include "hotkeyMenu.h"
#include <regex>
#include "soundManager.h"
#include "main.h"

#include "gui/hotkeyBinder.h"
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
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopLeft)->setMargins(FRAME_MARGIN / 2);

    top_row = new GuiElement(container, "TOP_ROW_CONTAINER");
    top_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::TopLeft);

    rebinding_ui = new GuiPanel(container, "REBINDING_UI_CONTAINER");
    rebinding_ui->setSize(GuiElement::GuiSizeMax, KEY_COLUMN_HEIGHT)->setPosition(0, KEY_COLUMN_TOP, sp::Alignment::TopLeft);
    info_container = new GuiElement(container, "info_container_CONTAINER");
    info_container->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, KEY_COLUMN_TOP+KEY_COLUMN_HEIGHT, sp::Alignment::TopLeft);
    bottom_row = new GuiElement(container, "BOTTOM_ROW_CONTAINER");
    bottom_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setPosition(0, 0, sp::Alignment::BottomLeft);

    // Single-column layout
    // Top: Title and category navigation

    // Title label
    (new GuiLabel(top_row, "CONFIGURE_KEYBOARD_LABEL", tr("Configure Keyboard/Joystick"), 30))->addBackground()->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(350, GuiElement::GuiSizeMax);

    // Category selector
    // Get a list of hotkey categories
    category_list = sp::io::Keybinding::getCategories();
    (new GuiSelector(top_row, "Category", [this](int index, string value)
    {
        HotkeyMenu::setCategory(index);
    }))->setOptions(category_list)->setSelectionIndex(category_index)->setSize(300, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::TopCenter);

    // Correctly initialize GuiElementListbox with a valid func_t argument
    rebinding_container = new GuiElementListbox(rebinding_ui, "HOTKEY_LISTBOX", FRAME_MARGIN / 2, ROW_HEIGHT , [this]()
    {
        // Handle selection changes here if needed
    });
    rebinding_container->setPosition(0, 0, sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax,  GuiElement::GuiSizeMax);
    rebinding_container->setMargins(FRAME_MARGIN / 2);

    HotkeyMenu::setCategory(1);

    // for(int test = 0; test<20; test++){

    //     // Creates a container for the hotkey label
    //     GuiElement *container = new GuiElement(listbox, "HOTKEY_LABEL_CONTAINER_" + std::to_string(test));
    //     container->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setAttribute("layout", "horizontal");
    //     // Adds two labels to the container
    //     GuiElement *label = new GuiLabel(container, "HOTKEY_LABEL_" + std::to_string(test), tr("Hotkey %d", test), 30);
    //     GuiElement *key_label = new GuiLabel(container, "HOTKEY_KEY_LABEL_" + std::to_string(test), tr("Key %d", test), 30);

    //     // Place the two labels hperically in the container
    //     label->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT);
    //     key_label->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT);
        

    //     listbox->addElement(container);
    // }




    // Bottom: Menu navigation
    // Back button to return to the Options menu
    (new GuiScrollText(info_container, "INFO_LABEL", tr("Left Click: Assign input. Middle Click: Add input. Right Click: Delete inputs.\nPossible inputs: Keyboard keys, joystick buttons, joystick axes.")))->setPosition(10, 0, sp::Alignment::TopCenter)->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT*3);
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

    rebinding_container->destroyAndClear();

    

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
        GuiElement* rebinding_row = new GuiElement(rebinding_container, "");
        rebinding_row->setSize(GuiElement::GuiSizeMax, ROW_HEIGHT)->setAttribute("layout", "horizontal");

        // Add a label to the current row.
        label_entries.push_back(new GuiLabel(rebinding_row, "HOTKEY_LABEL_" + item->getName(), item->getLabel(), 30));
        label_entries.back()->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN , 0);

        // Add a hotkey rebinding field to the current row.
        text_entries.push_back(new GuiHotkeyBinder(rebinding_row, "HOTKEY_VALUE_" + item->getName(), item));
        text_entries.back()->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setMargins(0, 0, FRAME_MARGIN , 0);

        rebinding_container->addElement(rebinding_row);
    }
}

void HotkeyMenu::pageHotkeys(int direction)
{
}
