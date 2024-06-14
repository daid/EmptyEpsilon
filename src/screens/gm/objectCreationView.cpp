#include "objectCreationView.h"
#include "GMActions.h"
#include "components/faction.h"
#include "ecs/query.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
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

    faction_selector = new GuiSelector(box, "FACTION_SELECTOR", nullptr);
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        faction_selector->addEntry(info.locale_name, info.name);
    faction_selector->setSelectionIndex(0);
    faction_selector->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(300, 50);

    category_selector = new GuiSelector(box, "CATEGORY_SELECTOR", [this](int index, string)
    {
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
    category_selector->setPosition(20, 70, sp::Alignment::TopLeft)->setSize(300, 50);
    object_list = new GuiListbox(box, "OBJECT_LIST", [this](int index, string value) {
        for(auto& info : spawn_list) {
            if (info.category == category_selector->getSelectionValue() && info.label == value) {
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
            }
        }
    });
    object_list->setPosition(320, 20)->setSize(300, 600);

    (new GuiButton(box, "CLOSE_BUTTON", tr("button", "Cancel"), [this]() {
        this->hide();
    }))->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50);
}

bool GuiObjectCreationView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{   //Catch clicks.
    return true;
}
