#pragma once

#include "gui/gui2_overlay.h"
#include "gameGlobalInfo.h"


class GuiSelector;
class GuiListbox;
class GuiContainer;
class GuiScrollText;
class GuiTextEntry;

class GuiObjectCreationView : public GuiOverlay
{
private:
    GuiSelector* faction_selector = nullptr;
    GuiListbox* category_selector = nullptr;
    GuiTextEntry* object_filter = nullptr;
    GuiListbox* object_list = nullptr;
    GuiScrollText* description = nullptr;
    std::vector<GameGlobalInfo::ObjectSpawnInfo> spawn_list;
    int last_selection_index = -1;
public:
    GuiObjectCreationView(GuiContainer* owner);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
};
