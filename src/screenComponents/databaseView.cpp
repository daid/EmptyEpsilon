#include "databaseView.h"
#include "scienceDatabase.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_scrolltext.h"

#include "screenComponents/rotatingModelView.h"

DatabaseViewComponent::DatabaseViewComponent(GuiContainer* owner)
: GuiElement(owner, "DATABASE_VIEW")
{
    database_entry = nullptr;

    item_list = new GuiListbox(this, "DATABASE_ITEM_LIST", [this](int index, string value) {
        if (database_entry)
            database_entry->destroy();
        
        database_entry = new GuiElement(this, "DATABASE_ENTRY");
        database_entry->setPosition(400, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        
        GuiAutoLayout* layout = new GuiAutoLayout(database_entry, "DATABASE_ENTRY_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
        layout->setPosition(0, 0, ATopLeft)->setSize(400, GuiElement::GuiSizeMax);
        
        P<ScienceDatabase> entry;
        if (selected_entry)
        {
            if (index == 0)
            {
                selected_entry = selected_entry->parent;
                fillListBox();
                return;
            }else{
                entry = selected_entry->items[index - 1];
            }
        }
        else
        {
            entry = ScienceDatabase::science_databases[index];
        }
        for(unsigned int n=0; n<entry->keyValuePairs.size(); n++)
        {
            (new GuiKeyValueDisplay(layout, "", 0.6, entry->keyValuePairs[n].key, entry->keyValuePairs[n].value))->setSize(GuiElement::GuiSizeMax, 40);
        }
        if (entry->longDescription.length() > 0)
        {
            (new GuiScrollText(layout, "DATABASE_LONG_DESCRIPTION", entry->longDescription))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        if (entry->model_data)
        {
            float x = 400;
            if (entry->keyValuePairs.size() == 0 && entry->longDescription.length() == 0)
                x = 0;
            (new GuiRotatingModelView(database_entry, "DATABASE_MODEL_VIEW", entry->model_data))->setPosition(x, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMatchWidth);
        }
        if (entry->items.size() > 0)
        {
            selected_entry = entry;
            fillListBox();
        }
    });
    item_list->setPosition(0, 0, ATopLeft)->setMargins(50, 50, 50, 150)->setSize(350, GuiElement::GuiSizeMax);
    fillListBox();
}

void DatabaseViewComponent::fillListBox()
{
    item_list->setOptions({});
    item_list->setSelectionIndex(-1);
    if (!selected_entry)
    {
        foreach(ScienceDatabase, sd, ScienceDatabase::science_databases)
        {
            item_list->addEntry(sd->getName(), sd->getName());
        }
    }else{
        item_list->addEntry("Back", "");
        foreach(ScienceDatabase, sd, selected_entry->items)
        {
            item_list->addEntry(sd->getName(), sd->getName());
        }
    }
}
