#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "dockingButton.h"

GuiDockingButton::GuiDockingButton(GuiContainer* owner, string id, P<PlayerSpaceship> targetSpaceship)
: GuiButton(owner, id, "", [this]() { click(); }), target_spaceship(targetSpaceship)
{
    setIcon("gui/icons/docking");
}

void GuiDockingButton::click()
{
    if (!target_spaceship)
        return;
    switch(target_spaceship->docking_state)
    {
    case DS_NotDocking:
        target_spaceship->commandDock(findDockingTarget());
        break;
    case DS_Docking:
        target_spaceship->commandAbortDock();
        break;
    case DS_Docked:
        target_spaceship->commandUndock();
        break;
    }
}

void GuiDockingButton::onUpdate()
{
    setVisible(target_spaceship && target_spaceship->getCanDock());
}

void GuiDockingButton::onDraw(sf::RenderTarget& window)
{
    if (target_spaceship)
    {
        switch(target_spaceship->docking_state)
        {
        case DS_NotDocking:
            setText(tr("Request Dock"));
            if (target_spaceship->canStartDocking() && findDockingTarget())
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
    GuiButton::onDraw(window);
}

void GuiDockingButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && target_spaceship)
    {
        if (key.hotkey == "DOCK_ACTION")
        {
            switch(target_spaceship->docking_state)
            {
            case DS_NotDocking:
                target_spaceship->commandDock(findDockingTarget());
                break;
            case DS_Docking:
                target_spaceship->commandAbortDock();
                break;
            case DS_Docked:
                target_spaceship->commandUndock();
                break;
            }
        }
        else if (key.hotkey == "DOCK_REQUEST")
            target_spaceship->commandDock(findDockingTarget());
        else if (key.hotkey == "DOCK_ABORT")
            target_spaceship->commandAbortDock();
        else if (key.hotkey == "UNDOCK")
            target_spaceship->commandUndock();
    }
}

P<SpaceObject> GuiDockingButton::findDockingTarget()
{
    PVector<Collisionable> obj_list = CollisionManager::queryArea(target_spaceship->getPosition() - sf::Vector2f(1000, 1000), target_spaceship->getPosition() + sf::Vector2f(1000, 1000));
    P<SpaceObject> dock_object;
    foreach(Collisionable, obj, obj_list)
    {
        dock_object = obj;
        if (dock_object && dock_object != target_spaceship && dock_object->canBeDockedBy(target_spaceship) && (dock_object->getPosition() - target_spaceship->getPosition()) < 1000.0f + dock_object->getRadius())
            break;
        dock_object = NULL;
    }
    return dock_object;
}
