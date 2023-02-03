#include "playerInfo.h"
#include "repairCrew.h"
#include "shipInternalView.h"
#include "components/internalrooms.h"


GuiShipInternalView::GuiShipInternalView(GuiContainer* owner, string id, float room_size)
: GuiElement(owner, id), room_size(room_size), room_container(nullptr)
{
}

GuiShipInternalView* GuiShipInternalView::setShip(sp::ecs::Entity ship)
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
    auto ir = ship.getComponent<InternalRooms>();
    if (!ir)
        return this;

    room_container = new GuiShipRoomContainer(this, id + "_ROOM_CONTAINER", room_size, [this](glm::ivec2 position) {
        if (selected_crew_member)
            selected_crew_member->commandSetTargetPosition(position);
    });
    room_container->setPosition(0, 0, sp::Alignment::Center);
    auto room_min = ir->roomMin();
    auto max_size = ir->roomMax() - room_min;

    for(unsigned int n=0; n<ir->rooms.size(); n++)
    {
        auto& rt = ir->rooms[n];
        GuiShipRoom* room = new GuiShipRoom(room_container, id + "_ROOM_" + string(n), room_size, rt.size, nullptr);
        room->setPosition(glm::vec2(rt.position - room_min) * room_size, sp::Alignment::TopLeft);
        room->setSystem(ship, rt.system);
    }

    for(unsigned int n=0; n<ir->doors.size(); n++)
    {
        auto& dt = ir->doors[n];

        GuiShipDoor* door = new GuiShipDoor(room_container, id + "_DOOR_" + string(n), nullptr);
        door->setSize(room_size, room_size);
        if (dt.horizontal)
        {
            door->setHorizontal();
            door->setPosition(glm::vec2(dt.position - room_min) * room_size - glm::vec2(0, room_size / 2.0f));
        }else{
            door->setPosition(glm::vec2(dt.position - room_min) * room_size - glm::vec2(room_size / 2.0f, 0));
        }
    }
    room_container->setSize(glm::vec2(max_size) * room_size);

    return this;
}

void GuiShipInternalView::onDraw(sp::RenderTarget& target)
{
    setShip(my_spaceship);

    if (!viewing_ship && room_container)
    {
        room_container->destroy();
        room_container = nullptr;
        crew_list.clear();
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

void GuiShipInternalView::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        if (keys.engineering_next_repair_crew.getDown())
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
            if (keys.engineering_repair_crew_up.getDown())
                selected_crew_member->commandSetTargetPosition(glm::ivec2(selected_crew_member->position + glm::vec2(0.5, 0.5)) + glm::ivec2(0, -1));
            if (keys.engineering_repair_crew_down.getDown())
                selected_crew_member->commandSetTargetPosition(glm::ivec2(selected_crew_member->position + glm::vec2(0.5, 0.5)) + glm::ivec2(0, 1));
            if (keys.engineering_repair_crew_left.getDown())
                selected_crew_member->commandSetTargetPosition(glm::ivec2(selected_crew_member->position + glm::vec2(0.5, 0.5)) + glm::ivec2(-1, 0));
            if (keys.engineering_repair_crew_right.getDown())
                selected_crew_member->commandSetTargetPosition(glm::ivec2(selected_crew_member->position + glm::vec2(0.5, 0.5)) + glm::ivec2(1, 0));
        }
    }
}

GuiShipRoomContainer::GuiShipRoomContainer(GuiContainer* owner, string id, float room_size, func_t func)
: GuiElement(owner, id), room_size(room_size), func(func)
{
}

bool GuiShipRoomContainer::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiShipRoomContainer::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position) && func)
    {
        func(glm::ivec2((position - rect.position) / room_size));
    }
}

GuiShipRoom::GuiShipRoom(GuiContainer* owner, string id, float room_size, glm::ivec2 dimensions, func_t func)
: GuiElement(owner, id), system(ShipSystem::Type::None), room_size(room_size), func(func)
{
    setSize(glm::vec2(dimensions) * room_size);
}

void GuiShipRoom::onDraw(sp::RenderTarget& renderer)
{
    float f = 1.0;
    ShipSystem* sys = nullptr;
    if (ship)
        sys = ShipSystem::get(ship, system);
    if (sys)
        f = std::max(0.0f, sys->health);
    renderer.drawStretchedHV(rect, rect.size.x * 0.25f, "room_background", glm::u8vec4(255, 255 * f, 255 * f, 255));

    if (system != ShipSystem::Type::None && ship && sys)
    {
        std::string_view icon;
        switch(system)
        {
        case ShipSystem::Type::Reactor:
            icon = "gui/icons/system_reactor.png";
            break;
        case ShipSystem::Type::BeamWeapons:
            icon = "gui/icons/system_beam";
            break;
        case ShipSystem::Type::MissileSystem:
            icon = "gui/icons/system_missile";
            break;
        case ShipSystem::Type::Maneuver:
            icon = "gui/icons/system_maneuver";
            break;
        case ShipSystem::Type::Impulse:
            icon = "gui/icons/system_impulse";
            break;
        case ShipSystem::Type::Warp:
            icon = "gui/icons/system_warpdrive";
            break;
        case ShipSystem::Type::JumpDrive:
            icon = "gui/icons/system_jumpdrive";
            break;
        case ShipSystem::Type::FrontShield:
            icon = "gui/icons/shields-fore";
            break;
        case ShipSystem::Type::RearShield:
            icon = "gui/icons/shields-aft";
            break;
        default:
            icon = "particle.png";
            break;
        }
        renderer.drawSprite(icon, getCenterPoint(), room_size);
    }
}

bool GuiShipRoom::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (func)
        return true;
    return false;
}

void GuiShipRoom::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position) && func)
    {
        glm::vec2 ship_click_pos(position.x - rect.position.x, position.y - rect.position.y);
        ship_click_pos += getPositionOffset();
        func(glm::ivec2(ship_click_pos.x / room_size, ship_click_pos.y / room_size));
    }
}

GuiShipDoor::GuiShipDoor(GuiContainer* owner, string id, func_t func)
: GuiElement(owner, id), horizontal(false), func(func)
{
}

void GuiShipDoor::onDraw(sp::RenderTarget& renderer)
{
    if (horizontal)
        renderer.drawSprite("room_door.png", getCenterPoint(), rect.size.y);
    else
        renderer.drawRotatedSprite("room_door.png", getCenterPoint(), rect.size.y, 90);
}

bool GuiShipDoor::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (func)
        return true;
    return false;
}

void GuiShipDoor::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position) && func)
        func();
}

GuiShipCrew::GuiShipCrew(GuiContainer* owner, string id, P<RepairCrew> crew, func_t func)
: GuiElement(owner, id), crew(crew), func(func)
{
}

void GuiShipCrew::onDraw(sp::RenderTarget& renderer)
{
    if (!crew)
        return;
    setPosition(crew->position * getSize().x, sp::Alignment::TopLeft);

    float rotation = 0;
    string tex = "topdownCrew0.png";
    if (crew->action == RC_Move)
        tex = "topdownCrew" + string(int(crew->action_delay * 12) % 6) + ".png";
    switch(crew->direction)
    {
    case RC_Left: rotation = 180; break;
    case RC_Right: rotation = 0; break;
    case RC_None:
    case RC_Up: rotation = -90; break;
    case RC_Down: rotation = 90; break;
    }
    renderer.drawRotatedSprite(tex, getCenterPoint(), getSize().x, rotation);
    if (crew->selected)
    {
        renderer.drawSprite("redicule.png", getCenterPoint(), getSize().x);
    }
}

bool GuiShipCrew::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiShipCrew::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position) && func)
        func(crew);
}
