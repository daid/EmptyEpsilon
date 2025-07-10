#include "objectCreationView.h"
#include "GMActions.h"
#include "components/faction.h"
#include "ecs/query.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_textentry.h"
#include "menus/luaConsole.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "components/collision.h"
#include <unordered_set>


GuiObjectCreationView::GuiObjectCreationView(GuiContainer* owner)
: GuiOverlay(owner, "OBJECT_CREATE_SCREEN", glm::u8vec4(0, 0, 0, 128))
{
    spawn_list = gameGlobalInfo->getGMSpawnableObjects();
    std::sort(spawn_list.begin(), spawn_list.end(), [](const GameGlobalInfo::ObjectSpawnInfo& a, const GameGlobalInfo::ObjectSpawnInfo& b) -> bool {
        return a.label.compare(b.label) < 0;
    });

    GuiPanel* box = new GuiPanel(this, "FRAME");
    box->setPosition(0, 0, sp::Alignment::Center)->setSize(1000, 650);
    box->setAttribute("padding", "20");
    box->setAttribute("layout", "horizontal");

    auto col1 = new GuiElement(box, "COLUMN_1");
    col1->setAttribute("stretch", "true");
    col1->setAttribute("layout", "vertical");
    auto col2 = new GuiElement(box, "COLUMN_2");
    col2->setAttribute("stretch", "true");
    col2->setAttribute("margin", "20,0");
    col2->setAttribute("layout", "vertical");
    auto col3 = new GuiElement(box, "COLUMN_3");
    col3->setAttribute("stretch", "true");
    col3->setAttribute("layout", "vertical");

    faction_selector = new GuiSelector(col1, "FACTION_SELECTOR", nullptr);
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        faction_selector->addEntry(info.locale_name, info.name);
    faction_selector->setSelectionIndex(0);
    faction_selector->setSize(GuiElement::GuiSizeMax, 50);

    category_selector = new GuiListbox(col1, "CATEGORY_SELECTOR", [this](int index, string)
    {
        last_selection_index = -1;
        object_list->clear();
        object_filter->setText("");
        for(const auto& info : spawn_list) {
            if (info.category == category_selector->getSelectionValue()) {
                object_list->addEntry(info.label, info.label);
            }
        }
    });
    std::unordered_set<string> categories_added;
    for(const auto& info : spawn_list) {
        if (categories_added.find(info.category) == categories_added.end()) {
            categories_added.insert(info.category);
            category_selector->addEntry(info.category, info.category);
        }
    }
    category_selector->setSelectionIndex(0);
    category_selector->setAttribute("stretch", "true");

    object_filter = new GuiTextEntry(col2, "OBJECT_FILTER", "");
    object_filter->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("fill_width", "true");
    object_filter->callback([this](string value) {
        value = value.lower();
        last_selection_index = -1;
        object_list->clear();
        for(const auto& info : spawn_list) {
            if (info.category == category_selector->getSelectionValue() && info.label.lower().find(value) >= 0) {
                object_list->addEntry(info.label, info.label);
            }
        }
    });
    object_list = new GuiListbox(col2, "OBJECT_LIST", [this](int index, string value) {
        for(auto& info : spawn_list) {
            if (info.category == category_selector->getSelectionValue() && info.label == value) {
                if (last_selection_index == index) {
                    gameGlobalInfo->on_gm_click = [&info, this] (glm::vec2 position)
                    {
                        auto res = info.create_callback.call<sp::ecs::Entity>();
                        LuaConsole::checkResult(res);
                        if (res.isOk()) {
                            auto e = res.value();
                            auto transform = e.getComponent<sp::Transform>();
                            if (transform)
                                transform->setPosition(position);
                            if (auto faction = e.getComponent<Faction>()) {
                                for(auto [entity, info] : sp::ecs::Query<FactionInfo>()) {
                                    if (info.name == faction_selector->getSelectionValue())
                                        faction->entity = entity;
                                }
                            }
                        }
                    };
                } else {
                    description->setText(info.description);
                }
            }
        }
        last_selection_index = index;
    });
    object_list->setTextSize(20)->setButtonHeight(30)->setAttribute("stretch", "true");
    for(const auto& info : spawn_list) {
        if (info.category == category_selector->getSelectionValue()) {
            object_list->addEntry(info.label, info.label);
        }
    }

    description = new GuiScrollText(col3, "DESCRIPTION", "");
    description->setAttribute("stretch", "true");

    (new GuiButton(col1, "CLOSE_BUTTON", tr("button", "Cancel"), [this]() {
        this->hide();
    }))->setSize(300, 50);
}

bool GuiObjectCreationView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{   //Catch clicks.
    return true;
}
