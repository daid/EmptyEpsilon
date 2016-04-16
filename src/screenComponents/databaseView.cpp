#include "databaseView.h"
#include "scienceDatabase.h"

#include "screenComponents/rotatingModelView.h"

DatabaseViewComponent::DatabaseViewComponent(GuiContainer* owner)
: GuiElement(owner, "DATABASE_VIEW")
{
    database_entry = nullptr;

    item_list = new GuiListbox(this, "DATABASE_ITEM_LIST", [this](int index, string value) {
        if (database_entry)
            database_entry->destroy();
        
        database_entry = new GuiElement(this, "DATABASE_ENTRY");
        database_entry->setPosition(500, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        
        GuiAutoLayout* layout = new GuiAutoLayout(database_entry, "DATABASE_ENTRY_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
        layout->setPosition(0, 0, ATopLeft)->setSize(400, GuiElement::GuiSizeMax);
        
        P<ScienceDatabaseEntry> entry = ScienceDatabase::scienceDatabaseList[category_list->getSelectionIndex()]->items[index];
        for(unsigned int n=0; n<entry->keyValuePairs.size(); n++)
        {
            (new GuiKeyValueDisplay(layout, "DATABASE_ENTRY_" + string(n), 0.7, entry->keyValuePairs[n].key, entry->keyValuePairs[n].value))->setSize(GuiElement::GuiSizeMax, 40);
        }
        if (entry->longDescription.length() > 0)
        {
            (new GuiScrollText(layout, "DATABASE_LONG_DESCRIPTION", entry->longDescription))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        if (entry->model_template)
        {
            (new GuiRotatingModelView(database_entry, "DATABASE_MODEL_VIEW", entry->model_template->model_data))->setPosition(400, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMatchWidth);
        }
    });
    category_list = new GuiListbox(this, "DATABASE_CAT_LIST", [this](int index, string value) {
        item_list->setOptions({});
        foreach(ScienceDatabaseEntry, entry, ScienceDatabase::scienceDatabaseList[index]->items)
        {
            item_list->addEntry(entry->name, entry->name);
        }
        item_list->setSelectionIndex(-1);

        if (database_entry)
            database_entry->destroy();
        database_entry = nullptr;
    });
    category_list->setPosition(20, 50, ATopLeft)->setSize(200, GuiElement::GuiSizeMax);
    item_list->setPosition(240, 50, ATopLeft)->setSize(250, GuiElement::GuiSizeMax);
    foreach(ScienceDatabase, sd, ScienceDatabase::scienceDatabaseList)
    {
        category_list->addEntry(sd->getName(), sd->getName());
    }
}
