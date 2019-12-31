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

void GuiDockingButton::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        switch(my_spaceship->docking_state)
        {
        case DS_NotDocking:
            setText("Request Dock");
            if (my_spaceship->canStartDocking() && findDockingTarget())
            {
                enable();
            }else{
                disable();
            }
            break;
        case DS_Docking:
            setText("Cancel Docking");
            enable();
            break;
        case DS_Docked:
            setText("Undock");
            enable();
            break;
        }
    }
    GuiButton::onDraw(window);
}

void GuiDockingButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && my_spaceship)
    {
        if (key.hotkey == "DOCK_ACTION")
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
        else if (key.hotkey == "DOCK_REQUEST")
            my_spaceship->commandDock(findDockingTarget());
        else if (key.hotkey == "DOCK_ABORT")
            my_spaceship->commandAbortDock();
        else if (key.hotkey == "UNDOCK")
            my_spaceship->commandUndock();
    }
}

P<SpaceObject> GuiDockingButton::findDockingTarget()
{
    PVector<Collisionable> obj_list = CollisionManager::queryArea(my_spaceship->getPosition() - sf::Vector2f(1000, 1000), my_spaceship->getPosition() + sf::Vector2f(1000, 1000));
    P<SpaceObject> dock_object;
    foreach(Collisionable, obj, obj_list)
    {
        dock_object = obj;
        if (dock_object && dock_object != my_spaceship && dock_object->canBeDockedBy(my_spaceship) && (dock_object->getPosition() - my_spaceship->getPosition()) < 1000.0f + dock_object->getRadius())
            break;
        dock_object = NULL;
    }
    return dock_object;
}
