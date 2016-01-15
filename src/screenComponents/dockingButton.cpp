#include "playerInfo.h"
#include "dockingButton.h"

GuiDockingButton::GuiDockingButton(GuiContainer* owner, string id)
: GuiButton(owner, id, "", [this]() { click(); })
{
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
            setText("Docking...");
            disable();
            break;
        case DS_Docked:
            setText("Undock");
            enable();
            break;
        }
    }
    GuiButton::onDraw(window);
}

P<SpaceObject> GuiDockingButton::findDockingTarget()
{
    PVector<Collisionable> obj_list = CollisionManager::queryArea(my_spaceship->getPosition() - sf::Vector2f(1000, 1000), my_spaceship->getPosition() + sf::Vector2f(1000, 1000));
    P<SpaceObject> dock_object;
    foreach(Collisionable, obj, obj_list)
    {
        dock_object = obj;
        if (dock_object && dock_object->canBeDockedBy(my_spaceship) && (dock_object->getPosition() - my_spaceship->getPosition()) < 1000.0f + dock_object->getRadius())
            break;
        dock_object = NULL;
    }
    return dock_object;
}
