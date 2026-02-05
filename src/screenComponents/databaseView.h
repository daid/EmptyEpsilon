#pragma once

#include "gui/gui2_element.h"
#include "ecs/entity.h"

class GuiListbox;
class GuiButton;

class DatabaseViewComponent : public GuiElement
{
public:
    DatabaseViewComponent(GuiContainer* owner);

    bool findAndDisplayEntry(string name);
    DatabaseViewComponent* setDetailsPadding(int padding);
    DatabaseViewComponent* setItemsPadding(int padding);

private:
    bool findAndDisplayEntry(string name, sp::ecs::Entity parent);
    // Fill the selection listbox with options from the selected_entry, or the main database list if selected_entry is nullptr
    void fillListBox();
    void display();

    sp::ecs::Entity selected_entry;
    string back_entry;
    GuiElement* navigation_element = nullptr;
    GuiButton* back_button = nullptr;
    GuiListbox* item_list = nullptr;
    GuiElement* keyvalue_container = nullptr;
    GuiElement* details_container = nullptr;

    static constexpr int navigation_width = 400;
    int details_padding = 0;
    int items_padding = 0;
};
