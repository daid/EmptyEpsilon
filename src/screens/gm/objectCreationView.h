#ifndef OBJECT_CREATION_VIEW_H
#define OBJECT_CREATION_VIEW_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_listbox.h"

class GuiSelector;
class GuiContainer;

class GuiObjectCreationView : public GuiOverlay
{
private:
    struct ShipEntry {
        string template_name;
        string class_name;
        string subclass_name;
    };
    std::vector<ShipEntry> ship_template_entries;
    GuiSelector* faction_selector;
    GuiSelector* player_cpu_selector;
public:
    GuiListbox* cpu_ship_listbox;
    GuiListbox* player_ship_listbox;
    GuiObjectCreationView(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;

    void setCreateScript(const string create, const string configure = "");
};

#endif//OBJECT_CREATION_VIEW_H
