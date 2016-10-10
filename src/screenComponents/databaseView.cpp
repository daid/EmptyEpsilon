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
        P<ScienceDatabase> entry;
        if (selected_entry)
        {
            if (index == 0)
            {
                selected_entry = selected_entry->parent;
                fillListBox();
            }else{
                entry = selected_entry->items[index - 1];
            }
        }
        else
        {
            entry = ScienceDatabase::science_databases[index];
        }
        display(entry);
    });
    item_list->setPosition(0, 0, ATopLeft)->setMargins(20, 20, 20, 130)->setSize(400, GuiElement::GuiSizeMax);
    fillListBox();
}

bool DatabaseViewComponent::findAndDisplayEntry(string name)
{
    foreach(ScienceDatabase, sd, ScienceDatabase::science_databases)
    {
        if (findAndDisplayEntry(name, sd))
            return true;
    }
    return false;
}

bool DatabaseViewComponent::findAndDisplayEntry(string name, P<ScienceDatabase> parent)
{
    foreach(ScienceDatabase, sd, parent->items)
    {
        if (sd->getName() == name)
        {
            selected_entry = parent;
            fillListBox();
            display(sd);
            item_list->setSelectionIndex(item_list->indexByValue(name));
            return true;
        }
        if (findAndDisplayEntry(name, sd))
            return true;
    }
    return false;
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

void DatabaseViewComponent::display(P<ScienceDatabase> entry)
{
    if (database_entry)
        database_entry->destroy();
    
    database_entry = new GuiElement(this, "DATABASE_ENTRY");
    database_entry->setPosition(400, 20, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    GuiAutoLayout* layout = new GuiAutoLayout(database_entry, "DATABASE_ENTRY_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    layout->setPosition(0, 0, ATopLeft)->setMargins(0, 0)->setSize(400, GuiElement::GuiSizeMax);

    if (!entry)
        return;

    for(unsigned int n=0; n<entry->keyValuePairs.size(); n++)
    {
        (new GuiKeyValueDisplay(layout, "", 0.37, entry->keyValuePairs[n].key, entry->keyValuePairs[n].value))->setSize(GuiElement::GuiSizeMax, 40);
    }
    if (entry->model_data)
    {
        float x = 450;
        if (entry->keyValuePairs.size() == 0 && entry->longDescription.length() == 0) {
            x = 0;
        }
        //TODO: std::min(GuiElement::GuiSizeMatchWidth, 370.0f)
        (new GuiRotatingModelView(database_entry, "DATABASE_MODEL_VIEW", entry->model_data))->setPosition(x, -50, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMatchWidth);

        if (entry->longDescription.length() > 0)
        {
            (new GuiScrollText(database_entry, "DATABASE_LONG_DESCRIPTION", entry->longDescription))->setTextSize(24)->setPosition(450,0,ABottomLeft)->setMargins(0, 0, 50, 50)->setSize(GuiElement::GuiSizeMax, 240);
        }
    } else if (entry->longDescription.length() > 0)
    {
        (new GuiScrollText(database_entry, "DATABASE_LONG_DESCRIPTION", entry->longDescription))->setTextSize(24)->setPosition(450,0,ATopLeft)->setMargins(0, 120, 50, 50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    if (entry->items.size() > 0)
    {
        selected_entry = entry;
        fillListBox();
    }
}

void DatabaseViewComponent::onHotkey(const HotkeyResult& key)
{
    if (key.category == "SCIENCE" && my_spaceship)
    {
        if (key.hotkey == "DATABASE_UP")
        {
            if (selected_entry)
                //item_list->setSelectionIndex(selected_entry);
            {
                if (index == 0)
                {
                    selected_entry = selected_entry->parent;
                    fillListBox();
                }else{
                    entry = selected_entry->items[index - 1];
                }
            }
            else
            {
                entry = ScienceDatabase::science_databases[index];
            }
            display(entry);
        }
    }
}
