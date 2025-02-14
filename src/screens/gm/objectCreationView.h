#ifndef OBJECT_CREATION_VIEW_H
#define OBJECT_CREATION_VIEW_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_listbox.h"
#include "gameGlobalInfo.h"


class GuiSelector;
class GuiContainer;

class GuiObjectCreationView : public GuiOverlay
{
private:
    GuiSelector* faction_selector;
    GuiSelector* category_selector;
    GuiListbox* object_list;
    std::vector<GameGlobalInfo::ObjectSpawnInfo> spawn_list;
public:
    GuiObjectCreationView(GuiContainer* owner);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//OBJECT_CREATION_VIEW_H
