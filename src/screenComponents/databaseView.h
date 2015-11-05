#ifndef DATABASE_VIEW_COMPONENT_H
#define DATABASE_VIEW_COMPONENT_H

#include "gui/gui2.h"

class DatabaseViewComponent : public GuiElement
{
private:
    GuiListbox* item_list;
    GuiListbox* category_list;
    GuiElement* database_entry;
public:
    DatabaseViewComponent(GuiContainer* owner);
};

#endif//DATABASE_VIEW_COMPONENT_H
