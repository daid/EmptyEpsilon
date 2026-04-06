#pragma once

#include "gui/gui2_panel.h"
#include "ecs/entity.h"

class GuiButton;
class GuiListbox;

// Button/listbox combo to manage docking state and select a docking target.
class GuiDockingButton : public GuiPanel
{
public:
    GuiDockingButton(GuiContainer* owner, string id);

    virtual void onUpdate() override;
private:
    static constexpr float item_height = 50.0f;

    GuiButton* action_button;
    GuiListbox* target_list;
    std::vector<sp::ecs::Entity> dock_targets;
    bool expanded = false;

    std::vector<sp::ecs::Entity> findDockingTargets();
};
