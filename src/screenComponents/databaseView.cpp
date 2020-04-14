#include <i18n.h>
#include "databaseView.h"
#include "scienceDatabase.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_image.h"
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
    item_list->setPosition(0, 0, ATopLeft)->setMargins(20, 20, 20, 20)->setSize(navigation_width, GuiElement::GuiSizeMax);
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
        item_list->addEntry(tr("Back"), "");
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
    database_entry->setPosition(navigation_width, 0, ATopLeft)->setMargins(20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    if (!entry)
        return;

    bool has_key_values = entry->keyValuePairs.size() > 0;
    bool has_image_or_model = entry->model_data || entry->image != "";
    bool has_text = entry->longDescription.length() > 0;

    int left_column_width = 0;
    if (has_key_values)
    {
        left_column_width = 400;
    }
    GuiAutoLayout* right = new GuiAutoLayout(database_entry, "DATABASE_ENTRY_RIGHT", GuiAutoLayout::LayoutHorizontalRows);
    right->setPosition(left_column_width, 0, ATopLeft)->setMargins(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    if (has_image_or_model)
    {
        GuiElement* visual = (new GuiElement(right, "DATABASE_VISUAL_ELEMENT"))->setMargins(0, 0, 0, 40)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        if (entry->model_data)
        {
            (new GuiRotatingModelView(visual, "DATABASE_MODEL_VIEW", entry->model_data))->setMargins(-100, -50)->setSize(GuiElement::GuiSizeMax, has_text ? GuiElement::GuiSizeMax : 450);
        }

        if(entry->image != "")
        {
            (new GuiImage(visual, "DATABASE_IMAGE", entry->image))->setScaleUp(false)->setMargins(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
    }
    if (has_text)
    {
        if (!has_image_or_model)
        {
            // make sure station and main screen buttons don't overlay the text
            if (!has_key_values)
            {
                right->setMargins(0, 10, 270, 0);
            } else {
                right->setMargins(0, 120, 0, 0);
            }
        }
        (new GuiScrollText(right, "DATABASE_LONG_DESCRIPTION", entry->longDescription))->setTextSize(24)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    // we render the left column second so it overlays the rotating 3D model
    if (has_key_values)
    {
        GuiAutoLayout* left = new GuiAutoLayout(database_entry, "DATABASE_ENTRY_LEFT", GuiAutoLayout::LayoutVerticalTopToBottom);
        left->setPosition(0, 0, ATopLeft)->setMargins(0, 0, 20, 0)->setSize(left_column_width, GuiElement::GuiSizeMax);

        for(unsigned int n=0; n<entry->keyValuePairs.size(); n++)
        {
            (new GuiKeyValueDisplay(left, "", 0.37, entry->keyValuePairs[n].key, entry->keyValuePairs[n].value))->setSize(GuiElement::GuiSizeMax, 40);
        }
    }

    if (entry->items.size() > 0)
    {
        selected_entry = entry;
        fillListBox();
    }
}
