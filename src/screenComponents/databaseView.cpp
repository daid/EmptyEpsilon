#include <i18n.h>
#include "databaseView.h"
#include "components/database.h"
#include "components/rendering.h"
#include "ecs/query.h"
#include "playerInfo.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_image.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_button.h"

#include "screenComponents/rotatingModelView.h"

DatabaseViewComponent::DatabaseViewComponent(GuiContainer* owner)
: GuiElement(owner, "DATABASE_VIEW")
{
    setAttribute("layout", "horizontal");

    // Setup the navigation bar.
    navigation_element = new GuiElement(this, "DB_NAV_BAR");
    navigation_element
        ->setSize(navigation_width, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");
    navigation_element
        ->setAttribute("margin", "0, 20, 0, 0");

    back_button = new GuiButton(navigation_element, "DB_BACK_BUTTON", tr("databaseView", "Back"),
        [this]()
        {
            selected_entry = sp::ecs::Entity::fromString(back_entry);
            display();
        }
    );
    back_button
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->hide()
        ->setAttribute("margin", "0, 0, 0, 20");

    item_list = new GuiListbox(navigation_element, "DB_ITEM_LIST",
        [this](int index, string value)
        {
            selected_entry = sp::ecs::Entity::fromString(value);
            display();
        }
    );
    item_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
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

DatabaseViewComponent* DatabaseViewComponent::setDetailsPadding(int padding)
{
    details_padding = std::max(0, padding);
    return this;
}

DatabaseViewComponent* DatabaseViewComponent::setItemsPadding(int padding)
{
    items_padding = std::max(0, padding);
    return this;
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
            back_button->show();
            back_entry = selected_database->parent.toString();
        }
        else if(parent_entry)
        {
            back_button->show();
            back_entry = parent_entry->parent.toString();
        }
    }
    else
    {
        back_button->hide();
        back_entry = "";
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
    if (keyvalue_container) keyvalue_container->destroy();
    if (details_container) details_container->destroy();

    keyvalue_container = new GuiElement(this, "DB_KV_CONTAINER");
    keyvalue_container
        ->setSize(400.0f, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");

    details_container = new GuiElement(this, "DB_DETAILS_CONTAINER");
    details_container
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");
    details_container
        ->setAttribute("margin", "20, 0, 0, 0");
    // Set conditional padding on details and item lists.
    details_container
        ->setAttribute("padding", "0, 0, " + static_cast<string>(details_padding) + ", 0");

    navigation_element
        ->setAttribute("padding", "0, 0, 0, " + static_cast<string>(items_padding));

    fillListBox();

    auto database = selected_entry.getComponent<Database>();
    if (!database) return;

    auto mrc = selected_entry.getComponent<MeshRenderComponent>();
    bool has_key_values = database->key_values.size() > 0;
    bool has_image_or_model = mrc || database->image != "";
    bool has_text = database->description.length() > 0;

    if (has_image_or_model)
    {
        GuiElement* visual = (new GuiElement(details_container, "DB_VISUAL_ELEMENT"))
            ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        if (mrc)
        {
            (new GuiRotatingModelView(visual, "DB_MODEL_VIEW", selected_entry))
                ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

            if (database->image != "")
            {
                (new GuiImage(visual, "DB_IMAGE", database->image))
                    ->setSize(32.0f, 32.0f);
            }
        }
        else if(database->image != "")
        {
            (new GuiImage(visual, "DB_IMAGE", database->image))
                ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
    }

    if (has_text)
    {
        (new GuiScrollFormattedText(details_container, "DB_LONG_DESCRIPTION", database->description))
            ->setTextSize(24.0f)
            ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    if (has_key_values)
    {
        for (auto& kv : database->key_values)
        {
            (new GuiKeyValueDisplay(keyvalue_container, "", 0.37f, kv.key, kv.value))
                ->setSize(GuiElement::GuiSizeMax, 40.0f);
        }
    }
    else
    {
        keyvalue_container->destroy();
        keyvalue_container = nullptr;
    }
}
