#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "dockingButton.h"
#include "systems/collision.h"
#include "systems/docking.h"
#include "components/collision.h"
#include "ecs/query.h"


GuiDockingButton::GuiDockingButton(GuiContainer* owner, string id)
: GuiButton(owner, id, "", [this]() { click(); })
{
    setIcon("gui/icons/docking");
}

void GuiDockingButton::click()
{
    if (!my_spaceship) { return; }
    auto port = my_spaceship.getComponent<DockingPort>();
    if (!port) { return; }

    switch(port->state)
    {
    case DockingPort::State::NotDocking:
        PlayerSpaceship::commandDock(findDockingTarget());
        break;
    case DockingPort::State::Docking:
        PlayerSpaceship::commandAbortDock();
        break;
    case DockingPort::State::Docked:
        PlayerSpaceship::commandUndock();
        break;
    }
}

void GuiDockingButton::onUpdate()
{
    if (!my_spaceship) { hide(); return; }
    auto port = my_spaceship.getComponent<DockingPort>();
    if (!port) { hide(); return; }

    if (isVisible())
    {
        if (keys.helms_dock_action.getDown())
        {
            switch(port->state)
            {
            case DockingPort::State::NotDocking:
                PlayerSpaceship::commandDock(findDockingTarget());
                break;
            case DockingPort::State::Docking:
                PlayerSpaceship::commandAbortDock();
                break;
            case DockingPort::State::Docked:
                PlayerSpaceship::commandUndock();
                break;
            }
        }
        else if (keys.helms_dock_request.getDown())
            PlayerSpaceship::commandDock(findDockingTarget());
        else if (keys.helms_dock_abort.getDown())
            PlayerSpaceship::commandAbortDock();
        else if (keys.helms_undock.getDown())
            PlayerSpaceship::commandUndock();
    }
}

void GuiDockingButton::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship) { return; }
    auto port = my_spaceship.getComponent<DockingPort>();
    if (!port) { return; }

    switch(port->state)
    {
    case DockingPort::State::NotDocking:
        setText(tr("Request Dock"));
        if (DockingSystem::canStartDocking(my_spaceship) && findDockingTarget())
        {
            enable();
        }else{
            disable();
        }
        break;
    case DockingPort::State::Docking:
        setText(tr("Cancel Docking"));
        enable();
        break;
    case DockingPort::State::Docked:
        setText(tr("Undock"));
        enable();
        break;
    }

    GuiButton::onDraw(renderer);
}

sp::ecs::Entity GuiDockingButton::findDockingTarget()
{
    if (!my_spaceship) { return {}; }
    auto port = my_spaceship.getComponent<DockingPort>();
    if (!port) { return {}; }
    auto my_transform = my_spaceship.getComponent<sp::Transform>();
    if (!my_transform) { return {}; }

    sp::ecs::Entity dock_object;
    for(auto [entity, bay, transform, physics] : sp::ecs::Query<DockingBay, sp::Transform, sp::Physics>())
    {
        if (entity == my_spaceship) continue;
        if (Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy) continue;
        if (port->canDockOn(bay) == DockingStyle::None) continue;
        if (glm::length(transform.getPosition() - my_transform->getPosition()) > 1000.0f + physics.getSize().x) continue;

        dock_object = entity;
        break;
    }
    return dock_object;
}
