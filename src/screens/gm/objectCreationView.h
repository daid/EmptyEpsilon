#ifndef OBJECT_CREATION_VIEW_H
#define OBJECT_CREATION_VIEW_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_listbox.h"

class GuiSelector;
class GuiContainer;

class GuiObjectCreationView : public GuiOverlay
{
private:
    GuiSelector* faction_selector;
    GuiSelector* player_cpu_selector;
public:
    GuiListbox* cpu_ship_listbox;
    GuiListbox* player_ship_listbox;
    GuiObjectCreationView(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual bool onMouseDown(sf::Vector2f position) override;

    void setCreateScript(const string create, const string configure = "");
};

#endif//OBJECT_CREATION_VIEW_H
