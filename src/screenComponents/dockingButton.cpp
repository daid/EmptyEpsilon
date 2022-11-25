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
    auto port = my_spaceship->entity.getComponent<DockingPort>();
    if (!port) { return; }

    switch(port->state)
    {
    case DockingPort::State::NotDocking:
        my_spaceship->commandDock(findDockingTarget());
        break;
    case DockingPort::State::Docking:
        my_spaceship->commandAbortDock();
        break;
    case DockingPort::State::Docked:
        my_spaceship->commandUndock();
        break;
    }
}

void GuiDockingButton::onUpdate()
{
    if (!my_spaceship) { hide(); return; }
    auto port = my_spaceship->entity.getComponent<DockingPort>();
    if (!port) { hide(); return; }

    if (isVisible())
    {
        if (keys.helms_dock_action.getDown())
        {
            switch(port->state)
            {
            case DockingPort::State::NotDocking:
                my_spaceship->commandDock(findDockingTarget());
                break;
            case DockingPort::State::Docking:
                my_spaceship->commandAbortDock();
                break;
            case DockingPort::State::Docked:
                my_spaceship->commandUndock();
                break;
            }
        }
        else if (keys.helms_dock_request.getDown())
            my_spaceship->commandDock(findDockingTarget());
        else if (keys.helms_dock_abort.getDown())
            my_spaceship->commandAbortDock();
        else if (keys.helms_undock.getDown())
            my_spaceship->commandUndock();
    }
}

void GuiDockingButton::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship) { return; }
    auto port = my_spaceship->entity.getComponent<DockingPort>();
    if (!port) { return; }

    switch(port->state)
    {
    case DockingPort::State::NotDocking:
        setText(tr("Request Dock"));
        if (DockingSystem::canStartDocking(my_spaceship->entity) && findDockingTarget())
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

P<SpaceObject> GuiDockingButton::findDockingTarget()
{
    if (!my_spaceship) { return nullptr; }
    auto port = my_spaceship->entity.getComponent<DockingPort>();
    if (!port) { return nullptr; }

    P<SpaceObject> dock_object;
    for(auto [entity, bay, position, physics, obj] : sp::ecs::Query<DockingBay, sp::Position, sp::Physics, SpaceObject*>())
    {
        if (obj == *my_spaceship) continue;
        if (obj->isEnemy(my_spaceship)) continue;
        if (port->canDockOn(bay) == DockingStyle::None) continue;
        if (glm::length(position.getPosition() - my_spaceship->getPosition()) > 1000.0f + physics.getSize().x) continue;

        dock_object = obj;
        break;
    }
    return dock_object;
}
