#ifndef DATABASE_VIEW_H
#define DATABASE_VIEW_H

#include "gui/gui2_element.h"
#include "ecs/entity.h"

class GuiListbox;
class GuiButton;

class DatabaseViewComponent : public GuiElement
{
public:
    DatabaseViewComponent(GuiContainer* owner);

    bool findAndDisplayEntry(string name);

private:
    bool findAndDisplayEntry(string name, sp::ecs::Entity parent);
    //Fill the selection listbox with options from the selected_entry, or the main database list if selected_entry is nullptr
    void fillListBox();
    void display();

    sp::ecs::Entity selected_entry;
    string back_entry;
    GuiButton* back_button = nullptr;
    GuiListbox* item_list = nullptr;
    GuiElement* keyvalue_container = nullptr;
    GuiElement* details_container = nullptr;

    static constexpr int navigation_width = 400;
};

#endif//DATABASE_VIEW_H
