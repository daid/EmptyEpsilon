#ifndef DATABASE_VIEW_H
#define DATABASE_VIEW_H

#include "gui/gui2_element.h"
#include "scienceDatabase.h"

class GuiListbox;

class DatabaseViewComponent : public GuiElement
{
public:
    DatabaseViewComponent(GuiContainer* owner, int navigation_height, bool show_navigation);

    bool findAndDisplayEntry(string name);
    bool findAndDisplayEntry(int32_t id);
    P<ScienceDatabase> getSelectedEntry();

private:
    P<ScienceDatabase> findEntryById(int32_t id);
    bool findAndDisplayEntry(string name, P<ScienceDatabase> parent);
    //Fill the selection listbox with options from the selected_entry, or the main database list if selected_entry is nullptr
    void fillListBox();
    void display();

    P<ScienceDatabase> selected_entry;
    GuiListbox* item_list;
    GuiElement* database_entry;

    bool show_navigation;
    int add_nav_margin_bottom;
    int navigation_width = 400;
};

#endif//DATABASE_VIEW_H
