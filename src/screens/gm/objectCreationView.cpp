#include "objectCreationView.h"
#include "GMActions.h"
#include "components/faction.h"
#include "ecs/query.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_scrolltext.h"
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

    auto row1 = new GuiElement(box, "row1");
    row1->setAttribute("stretch", "true");
    row1->setAttribute("layout", "vertical");
    auto row2 = new GuiElement(box, "row2");
    row2->setAttribute("stretch", "true");
    row2->setAttribute("layout", "vertical");
    auto row3 = new GuiElement(box, "row3");
    row3->setAttribute("stretch", "true");
    row3->setAttribute("layout", "vertical");

    faction_selector = new GuiSelector(row1, "FACTION_SELECTOR", nullptr);
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        faction_selector->addEntry(info.locale_name, info.name);
    faction_selector->setSelectionIndex(0);
    faction_selector->setSize(300, 50);

    category_selector = new GuiListbox(row1, "CATEGORY_SELECTOR", [this](int index, string)
    {
        last_selection_index = -1;
        object_list->clear();
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
    category_selector->setSize(300, 300)->setAttribute("fill_height", "true");

    object_list = new GuiListbox(row2, "OBJECT_LIST", [this](int index, string value) {
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

    description = new GuiScrollText(row3, "DESCRIPTION", "-");
    description->setAttribute("stretch", "true");

    (new GuiButton(row1, "CLOSE_BUTTON", tr("button", "Cancel"), [this]() {
        this->hide();
    }))->setSize(300, 50);
}

bool GuiObjectCreationView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{   //Catch clicks.
    return true;
}
