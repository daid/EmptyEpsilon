#include "playerInfo.h"
#include "repairCrew.h"
#include "shipInternalView.h"

GuiShipInternalView::GuiShipInternalView(GuiContainer* owner, string id, float room_size)
: GuiElement(owner, id), room_size(room_size), room_container(nullptr)
{
}

GuiShipInternalView* GuiShipInternalView::setShip(P<SpaceShip> ship)
{
    if (viewing_ship == ship)
        return this;
    viewing_ship = ship;
    if (room_container)
    {
        room_container->destroy();
        room_container = nullptr;
    }
    if (!ship)
        return this;
    
    P<ShipTemplate> st = ship->ship_template;
    
    room_container = new GuiShipRoomContainer(this, id + "_ROOM_CONTAINER", room_size, [this](sf::Vector2i position) {
        if (selected_crew_member)
            selected_crew_member->commandSetTargetPosition(position);
    });
    room_container->setPosition(0, 0, ACenter);
    sf::Vector2i max_size = st->interiorSize();
    
    for(unsigned int n=0; n<st->rooms.size(); n++)
    {
        ShipRoomTemplate& rt = st->rooms[n];
        GuiShipRoom* room = new GuiShipRoom(room_container, id + "_ROOM_" + string(n), room_size, rt.size, nullptr);
        room->setPosition(sf::Vector2f(rt.position) * room_size, ATopLeft);
        room->setSystem(ship, rt.system);
    }
    
    for(unsigned int n=0; n<st->doors.size(); n++)
    {
        ShipDoorTemplate& dt = st->doors[n];
        
        GuiShipDoor* door = new GuiShipDoor(room_container, id + "_DOOR_" + string(n), nullptr);
        door->setSize(room_size, room_size);
        if (dt.horizontal)
        {
            door->setHorizontal();
            door->setPosition(sf::Vector2f(dt.position) * room_size - sf::Vector2f(0, room_size / 2.0));
        }else{
            door->setPosition(sf::Vector2f(dt.position) * room_size - sf::Vector2f(room_size / 2.0, 0));
        }
    }
    room_container->setSize(sf::Vector2f(max_size) * room_size);
    
    return this;
}

void GuiShipInternalView::onDraw(sf::RenderTarget& window)
{
    setShip(my_spaceship);
        
    if (!viewing_ship && room_container)
    {
        room_container->destroy();
        room_container = nullptr;
    }else{
        PVector<RepairCrew> crew = getRepairCrewFor(viewing_ship);
        if (crew.size() != crew_list.size())
        {
            for(GuiShipCrew* c : crew_list)
                c->destroy();
            crew_list.clear();

            for(P<RepairCrew> rc : crew)
            {
                int id = rc->getMultiplayerId();
                crew_list.push_back(new GuiShipCrew(room_container, std::to_string(id) + "_CREW", rc, [this](P<RepairCrew> crew_member){
                    if (selected_crew_member)
                        selected_crew_member->selected = false;
                    selected_crew_member = crew_member;
                    if (selected_crew_member)
                        selected_crew_member->selected = true;
                }));
                crew_list.back()->setSize(room_size, room_size);
            }
        }
    }
}

void GuiShipInternalView::onHotkey(const HotkeyResult& key)
{
    if (key.category == "ENGINEERING" && my_spaceship)
    {
        if (key.hotkey == "NEXT_REPAIR_CREW")
        {
            PVector<RepairCrew> crew = getRepairCrewFor(viewing_ship);
            P<RepairCrew> crew_member;
            bool found = false;
            foreach(RepairCrew, rc, crew)
            {
                if (selected_crew_member == rc)
                {
                    found = true;
                }
                else if (found)
                {
                    crew_member = rc;
                    break;
                }
            }
            if (!crew_member)
            {
                foreach(RepairCrew, rc, crew)
                {
                    crew_member = rc;
                    break;
                }
            }
            if (crew_member)
            {
                if (selected_crew_member)
                    selected_crew_member->selected = false;
                selected_crew_member = crew_member;
                if (selected_crew_member)
                    selected_crew_member->selected = true;
            }
        }
        if (selected_crew_member)
        {
            if (key.hotkey == "REPAIR_CREW_MOVE_UP")
                selected_crew_member->commandSetTargetPosition(sf::Vector2i(selected_crew_member->position + sf::Vector2f(0.5, 0.5)) + sf::Vector2i(0, -1));
            if (key.hotkey == "REPAIR_CREW_MOVE_DOWN")
                selected_crew_member->commandSetTargetPosition(sf::Vector2i(selected_crew_member->position + sf::Vector2f(0.5, 0.5)) + sf::Vector2i(0, 1));
            if (key.hotkey == "REPAIR_CREW_MOVE_LEFT")
                selected_crew_member->commandSetTargetPosition(sf::Vector2i(selected_crew_member->position + sf::Vector2f(0.5, 0.5)) + sf::Vector2i(-1, 0));
            if (key.hotkey == "REPAIR_CREW_MOVE_RIGHT")
                selected_crew_member->commandSetTargetPosition(sf::Vector2i(selected_crew_member->position + sf::Vector2f(0.5, 0.5)) + sf::Vector2i(1, 0));
        }
    }
}

GuiShipRoomContainer::GuiShipRoomContainer(GuiContainer* owner, string id, float room_size, func_t func)
: GuiElement(owner, id), room_size(room_size), func(func)
{
}

bool GuiShipRoomContainer::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiShipRoomContainer::onMouseUp(sf::Vector2f position)
{
    if (rect.contains(position) && func)
    {
        func(sf::Vector2i((position - sf::Vector2f(rect.left, rect.top)) / room_size));
    }
}

GuiShipRoom::GuiShipRoom(GuiContainer* owner, string id, float room_size, sf::Vector2i dimensions, func_t func)
: GuiElement(owner, id), system(SYS_None), room_size(room_size), func(func)
{
    setSize(sf::Vector2f(dimensions) * room_size);
}

void GuiShipRoom::onDraw(sf::RenderTarget& window)
{
    float f = 1.0;
    if (ship && ship->hasSystem(system))
        f = std::max(0.0f, ship->systems[system].health);
    draw9Cut(window, rect, "room_background", sf::Color(255, 255 * f, 255 * f, 255));

    if (system != SYS_None && ship && ship->hasSystem(system))
    {
        sf::Sprite sprite;
        switch(system)
        {
        case SYS_Reactor:
            textureManager.setTexture(sprite, "gui/icons/system_reactor");
            break;
        case SYS_BeamWeapons:
            textureManager.setTexture(sprite, "gui/icons/system_beam");
            break;
        case SYS_MissileSystem:
            textureManager.setTexture(sprite, "gui/icons/system_missile");
            break;
        case SYS_Maneuver:
            textureManager.setTexture(sprite, "gui/icons/system_maneuver");
            break;
        case SYS_Impulse:
            textureManager.setTexture(sprite, "gui/icons/system_impulse");
            break;
        case SYS_Warp:
            textureManager.setTexture(sprite, "gui/icons/system_warpdrive");
            break;
        case SYS_JumpDrive:
            textureManager.setTexture(sprite, "gui/icons/system_jumpdrive");
            break;
        case SYS_FrontShield:
            textureManager.setTexture(sprite, "gui/icons/shields-fore");
            break;
        case SYS_RearShield:
            textureManager.setTexture(sprite, "gui/icons/shields-aft");
            break;
            break;
        case SYS_Docks:
            textureManager.setTexture(sprite, "gui/icons/docking");
            break;
        case SYS_Drones:
            textureManager.setTexture(sprite, "gui/icons/heading");
            break;
        default:
            textureManager.setTexture(sprite, "particle.png");
            break;
        }
        sprite.setPosition(getCenterPoint());
        sprite.setScale(room_size / sprite.getTextureRect().height, room_size / sprite.getTextureRect().height);
        window.draw(sprite);
    }
}

bool GuiShipRoom::onMouseDown(sf::Vector2f position)
{
    if (func)
        return true;
    return false;
}

void GuiShipRoom::onMouseUp(sf::Vector2f position)
{
    if (rect.contains(position) && func)
    {
        sf::Vector2f ship_click_pos(position.x - rect.left, position.y - rect.top);
        ship_click_pos += getPositionOffset();
        func(sf::Vector2i(ship_click_pos / room_size));
    }
}

GuiShipDoor::GuiShipDoor(GuiContainer* owner, string id, func_t func)
: GuiElement(owner, id), horizontal(false), func(func)
{
}

void GuiShipDoor::onDraw(sf::RenderTarget& window)
{
    sf::Sprite door_sprite;
    textureManager.setTexture(door_sprite, "room_door.png");
    door_sprite.setPosition(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
    float f = rect.height / float(door_sprite.getTextureRect().height);
    door_sprite.setScale(f, f);
    if (!horizontal)
        door_sprite.setRotation(90);
    window.draw(door_sprite);
}

bool GuiShipDoor::onMouseDown(sf::Vector2f position)
{
    if (func)
        return true;
    return false;
}

void GuiShipDoor::onMouseUp(sf::Vector2f position)
{
    if (rect.contains(position) && func)
        func();
}

GuiShipCrew::GuiShipCrew(GuiContainer* owner, string id, P<RepairCrew> crew, func_t func)
: GuiElement(owner, id), crew(crew), func(func)
{
}

void GuiShipCrew::onDraw(sf::RenderTarget& window)
{
    if (!crew)
        return;
    setPosition(crew->position * getSize().x, ATopLeft);
    
    sf::Sprite sprite;
    if (crew->action == RC_Move)
        textureManager.setTexture(sprite, "Tokka_WalkingMan.png", int(crew->action_delay * 12) % 6);
    else
        textureManager.setTexture(sprite, "Tokka_WalkingMan.png", 0);
    float f = getSize().y / float(sprite.getTextureRect().height);
    sprite.setScale(f, f);
    sprite.setPosition(getCenterPoint());
    switch(crew->direction)
    {
    case RC_Left:
        sprite.setRotation(180);
        break;
    case RC_Right:
        sprite.setRotation(0);
        break;
    case RC_None:
    case RC_Up:
        sprite.setRotation(-90);
        break;
    case RC_Down:
        sprite.setRotation(90);
        break;
    }
    window.draw(sprite);
    
    if (crew->selected)
    {
        sf::Sprite select_sprite;
        textureManager.setTexture(select_sprite, "redicule.png");
        select_sprite.setPosition(getCenterPoint());
        select_sprite.setScale(f, f);
        window.draw(select_sprite);
    }
}

bool GuiShipCrew::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiShipCrew::onMouseUp(sf::Vector2f position)
{
    if (rect.contains(position) && func)
        func(crew);
}
