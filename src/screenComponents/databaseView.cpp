#include <i18n.h>
#include "databaseView.h"
#include "components/database.h"
#include "components/rendering.h"
#include "ecs/query.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_image.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_scrolltext.h"

#include "screenComponents/rotatingModelView.h"

DatabaseViewComponent::DatabaseViewComponent(GuiContainer* owner)
: GuiElement(owner, "DATABASE_VIEW")
{
    item_list = new GuiListbox(this, "DATABASE_ITEM_LIST", [this](int index, string value) {
        selected_entry = sp::ecs::Entity::fromString(value);
        display();
    });
    setAttribute("layout", "horizontal");
    item_list->setMargins(20, 20, 20, 120)->setSize(navigation_width, GuiElement::GuiSizeMax);
    display();
}

bool DatabaseViewComponent::findAndDisplayEntry(string name)
{
    for(auto [entity, database] : sp::ecs::Query<Database>())
    {
        if (database.name == name)
        {
            selected_entry = entity;
            display();
            return true;
        }
    }
    return false;
}

void DatabaseViewComponent::fillListBox()
{
    item_list->setOptions({});
    item_list->setSelectionIndex(-1);

    // indices of child or sibling pages in the science_databases vector
    std::vector<std::pair<sp::ecs::Entity, Database*>> children;
    std::vector<std::pair<sp::ecs::Entity, Database*>> siblings;
    auto selected_database = selected_entry.getComponent<Database>();
    Database* parent_entry = nullptr;

    for(auto [entity, database] : sp::ecs::Query<Database>())
    {
        if(selected_database)
        {
            if(entity == selected_database->parent)
                parent_entry = &database;
            if(database.parent == selected_database->parent)
                siblings.push_back({entity, &database});
            if(database.parent == selected_entry)
                children.push_back({entity, &database});
        }
        else
        {
            if(!database.parent)
                siblings.push_back({entity, &database});
        }
    }

    if(selected_database)
    {
        if (children.size() != 0)
        {
            item_list->addEntry(tr("button", "Back"), selected_database->parent.toString());
        }
        else if(parent_entry)
        {
            item_list->addEntry(tr("button", "Back"), parent_entry->parent.toString());
        }
    }

    // the indices we actually want to display
    auto& display = children.size() > 0 ? children : siblings;

    sort(display.begin(), display.end(), [](const auto& A, const auto& B) -> bool {
        return A.second->name.lower() < B.second->name.lower();
    });

    for (auto [entity, database] : display)
    {
        int item_list_idx = item_list->addEntry(database->name, entity.toString());
        if (selected_entry && selected_entry.getComponent<Database>() == database)
        {
            item_list->setSelectionIndex(item_list_idx);
        }
    }
}

void DatabaseViewComponent::display()
{
    if (keyvalue_container)
        keyvalue_container->destroy();
    if (details_container)
        details_container->destroy();

    keyvalue_container = new GuiElement(this, "KEY_VALUE_CONTAINER");
    keyvalue_container->setMargins(20)->setSize(400, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    details_container = new GuiElement(this, "DETAILS_CONTAINER");
    details_container->setMargins(20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    details_container->layout.padding.top = 50;

    fillListBox();

    auto database = selected_entry.getComponent<Database>();
    if (!database)
        return;
    auto mrc = selected_entry.getComponent<MeshRenderComponent>();

    bool has_key_values = database->key_values.size() > 0;
    bool has_image_or_model = mrc || database->image != "";
    bool has_text = database->description.length() > 0;

    if (has_image_or_model)
    {
        GuiElement* visual = (new GuiElement(details_container, "DATABASE_VISUAL_ELEMENT"))->setMargins(0, 0, 0, 40)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        if (mrc)
        {
            (new GuiRotatingModelView(visual, "DATABASE_MODEL_VIEW", selected_entry))
                ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
            if(database->image != "")
            {
                (new GuiImage(visual, "DATABASE_IMAGE", database->image))->setMargins(0)->setSize(32, 32);
            }
        }
        else if(database->image != "")
        {
            auto image = new GuiImage(visual, "DATABASE_IMAGE", database->image);
            image->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
    }
    if (has_text)
    {
        (new GuiScrollText(details_container, "DATABASE_LONG_DESCRIPTION", database->description))->setTextSize(24)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    if (has_key_values)
    {
        for(auto& kv : database->key_values)
            (new GuiKeyValueDisplay(keyvalue_container, "", 0.37, kv.key, kv.value))->setSize(GuiElement::GuiSizeMax, 40);
    } else {
        keyvalue_container->destroy();
        keyvalue_container = nullptr;
    }
}
