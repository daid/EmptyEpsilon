#ifndef DATABASE_VIEW_COMPONENT_H
#define DATABASE_VIEW_COMPONENT_H

#include "gui/gui2_element.h"

class ScienceDatabase;
class GuiListbox;

class DatabaseViewComponent : public GuiElement
{
public:
    DatabaseViewComponent(GuiContainer* owner);

private:
    //Fill the selection listbox with options from the selected_entry, or the main database list if selected_entry is nullptr
    void fillListBox();

    P<ScienceDatabase> selected_entry;
    GuiListbox* item_list;
    GuiElement* database_entry;
};

#endif//DATABASE_VIEW_COMPONENT_H
