#include <i18n.h>
#include "playerInfo.h"
#include "dockingButton.h"
#include "gui/gui2_button.h"
#include "gui/gui2_listbox.h"
#include "systems/collision.h"
#include "systems/docking.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/faction.h"
#include "components/name.h"
#include "ecs/query.h"

GuiDockingButton::GuiDockingButton(GuiContainer* owner, string id)
: GuiPanel(owner, id)
{
    action_button = new GuiButton(this, id + "_BTN", tr("Request dock"),
        [this]()
        {
            if (!my_spaceship || !my_player_info) return;
            auto port = my_spaceship.getComponent<DockingPort>();
            if (!port) return;

            switch (port->state)
            {
            case DockingPort::State::NotDocking:
                dock_targets = findDockingTargets();
                // Expand list if it has more than one entry.
                // Otherwise, just dock.
                if (dock_targets.size() == 1)
                    my_player_info->commandDock(dock_targets[0]);
                else if (dock_targets.size() > 1) expanded = true;
                break;
            case DockingPort::State::Docking:
                my_player_info->commandAbortDock();
                break;
            case DockingPort::State::Docked:
                my_player_info->commandUndock();
                break;
            }
        }
    );
    action_button
        ->setIcon("gui/icons/docking")
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft);
    action_button->setAttribute("fill_width", "true");
    action_button->setAttribute("fill_height", "true");

    target_list = new GuiListbox(this, id + "_LIST",
        [this](int index, string value)
        {
            if (!my_player_info) return;
            expanded = false;
            if (value == "cancel") return;
            int idx = value.toInt();
            if (idx >= 0 && idx < static_cast<int>(dock_targets.size()))
                my_player_info->commandDock(dock_targets[idx]);

        }
    );
    target_list
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)
        ->hide();
    target_list->setAttribute("fill_width", "true");
    target_list->setAttribute("fill_height", "true");
}

void GuiDockingButton::onUpdate()
{
    if (!my_spaceship) { hide(); return; }
    auto port = my_spaceship.getComponent<DockingPort>();
    setVisible(port != nullptr);
    if (!port) return;

    // Keyboard shortcuts dock to the nearest.
    if (isVisible())
    {
        if (keys.helms_dock_action.getDown())
        {
            switch(port->state)
            {
            case DockingPort::State::NotDocking:
                {
                    auto targets = findDockingTargets();
                    if (!targets.empty())
                        my_player_info->commandDock(targets[0]);
                }
                break;
            case DockingPort::State::Docking:
                my_player_info->commandAbortDock();
                break;
            case DockingPort::State::Docked:
                my_player_info->commandUndock();
                break;
            }
        }
        else if (keys.helms_dock_request.getDown())
        {
            auto targets = findDockingTargets();
            if (!targets.empty())
                my_player_info->commandDock(targets[0]);
        }
        else if (keys.helms_dock_abort.getDown())
            my_player_info->commandAbortDock();
        else if (keys.helms_undock.getDown())
            my_player_info->commandUndock();
    }

    // Collapse the listbox when docking state changes away from NotDocking.
    if (port->state != DockingPort::State::NotDocking) expanded = false;

    // Update the docking list if it's expanded.
    if (expanded)
    {
        dock_targets = findDockingTargets();
        if (dock_targets.empty()) expanded = false;
        else
        {
            target_list->clear();
            for (int i = 0; i < static_cast<int>(dock_targets.size()); i++)
            {
                // Use the callsign if available for the entry name.
                string name = tr("Unknown");
                if (auto cs = dock_targets[i].getComponent<CallSign>())
                    name = cs->callsign;
                target_list->addEntry(name, string(i));
            }
            target_list->addEntry(tr("Cancel"), "cancel");

            // Expand height to fit all entries.
            layout.size.y = (dock_targets.size() + 1) * item_height;
            action_button->hide();
            target_list->show();
            return;
        }
    }

    // If collapsed, just show the action button.
    layout.size.y = item_height;
    target_list->hide();
    action_button->show();

    switch (port->state)
    {
    case DockingPort::State::NotDocking:
        dock_targets = findDockingTargets();
        action_button
            ->setText(tr("Request dock"))
            ->setEnable(DockingSystem::canStartDocking(my_spaceship) && !dock_targets.empty());
        break;
    case DockingPort::State::Docking:
        action_button
            ->setText(tr("Cancel docking"))
            ->enable();
        break;
    case DockingPort::State::Docked:
        action_button
            ->setText(tr("Undock"))
            ->enable();
        break;
    }
}

std::vector<sp::ecs::Entity> GuiDockingButton::findDockingTargets()
{
    std::vector<sp::ecs::Entity> targets;
    if (!my_spaceship) return targets;
    auto port = my_spaceship.getComponent<DockingPort>();
    if (!port) return targets;
    auto my_transform = my_spaceship.getComponent<sp::Transform>();
    if (!my_transform) return targets;

    for (auto [entity, bay, transform, physics] : sp::ecs::Query<DockingBay, sp::Transform, sp::Physics>())
    {
        if (entity == my_spaceship) continue;
        if (Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy) continue;
        if (port->canDockOn(bay) == DockingStyle::None) continue;
        if (glm::length(transform.getPosition() - my_transform->getPosition()) > 1000.0f + std::max(physics.getSize().x, physics.getSize().y)) continue;
        targets.push_back(entity);
    }

    return targets;
}
