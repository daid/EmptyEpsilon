#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "dockingButton.h"

GuiDockingButton::GuiDockingButton(GuiContainer* owner, string id)
: GuiButton(owner, id, "", [this]() { click(); })
{
    setIcon("gui/icons/docking");
}

void GuiDockingButton::click()
{
    if (!my_spaceship)
        return;
    switch(my_spaceship->docking_state)
    {
    case DS_NotDocking:
        my_spaceship->commandDock(findDockingTarget());
        break;
    case DS_Docking:
        my_spaceship->commandAbortDock();
        break;
    case DS_Docked:
        my_spaceship->commandUndock();
        break;
    }
}

void GuiDockingButton::onUpdate()
{
    setVisible(my_spaceship && my_spaceship->getCanDock());

    if (my_spaceship)
    {
        if (keys.helms_dock_action.getDown())
        {
            switch(my_spaceship->docking_state)
            {
            case DS_NotDocking:
                my_spaceship->commandDock(findDockingTarget());
                break;
            case DS_Docking:
                my_spaceship->commandAbortDock();
                break;
            case DS_Docked:
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
    if (my_spaceship)
    {
        switch(my_spaceship->docking_state)
        {
        case DS_NotDocking:
            setText(tr("Request Dock"));
            if (my_spaceship->canStartDocking() && findDockingTarget())
            {
                enable();
            }else{
                disable();
            }
            break;
        case DS_Docking:
            setText(tr("Cancel Docking"));
            enable();
            break;
        case DS_Docked:
            setText(tr("Undock"));
            enable();
            break;
        }
    }
    GuiButton::onDraw(renderer);
}

P<SpaceObject> GuiDockingButton::findDockingTarget()
{
    PVector<Collisionable> obj_list = CollisionManager::queryArea(my_spaceship->getPosition() - glm::vec2(1000, 1000), my_spaceship->getPosition() + glm::vec2(1000, 1000));
    P<SpaceObject> dock_object;
    foreach(Collisionable, obj, obj_list)
    {
        dock_object = obj;
        if (dock_object && dock_object != my_spaceship && dock_object->canBeDockedBy(my_spaceship) != DockStyle::None && glm::length(dock_object->getPosition() - my_spaceship->getPosition()) < 1000.0f + dock_object->getRadius())
            break;
        dock_object = NULL;
    }
    return dock_object;
}
