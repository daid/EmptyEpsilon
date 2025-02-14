#include "playerInfo.h"
#include "shipInternalView.h"
#include "components/internalrooms.h"
#include "ecs/query.h"


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
            my_player_info->commandCrewSetTargetPosition(selected_crew_member, position);
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
        for(auto [entity, ic] : sp::ecs::Query<InternalCrew>()) {
            if (ic.ship != viewing_ship) continue;
            bool found = false;
            for(auto gsc : crew_list) {
                if (gsc->crew == entity) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                crew_list.push_back(new GuiShipCrew(room_container, "CREW", entity, selected_crew_member, [this](sp::ecs::Entity crew_member){
                    selected_crew_member = crew_member;
                }));
                crew_list.back()->setSize(room_size, room_size);
            }
        }
        crew_list.erase(std::remove_if(crew_list.begin(), crew_list.end(), [](GuiShipCrew* cr) {
            if (!cr->crew) {
                cr->destroy();
                return true;
            }
            return false;
        }), crew_list.end());
    }
}

void GuiShipInternalView::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        if (keys.engineering_next_repair_crew.getDown())
        {
            bool found = false;
            sp::ecs::Entity first;
            for(auto [entity, ic] : sp::ecs::Query<InternalCrew>()) {
                if (ic.ship != viewing_ship) continue;
                if (!first) first = entity;
                if (entity == selected_crew_member) {
                    found = true;
                } else if (found) {
                    selected_crew_member = entity;
                    break;
                }
            }
            if (!found)
                selected_crew_member = first;
        }
        if (auto ic = selected_crew_member.getComponent<InternalCrew>())
        {
            if (keys.engineering_repair_crew_up.getDown())
                my_player_info->commandCrewSetTargetPosition(selected_crew_member, glm::ivec2(ic->position + glm::vec2(0.5, 0.5)) + glm::ivec2(0, -1));
            if (keys.engineering_repair_crew_down.getDown())
                my_player_info->commandCrewSetTargetPosition(selected_crew_member, glm::ivec2(ic->position + glm::vec2(0.5, 0.5)) + glm::ivec2(0, 1));
            if (keys.engineering_repair_crew_left.getDown())
                my_player_info->commandCrewSetTargetPosition(selected_crew_member, glm::ivec2(ic->position + glm::vec2(0.5, 0.5)) + glm::ivec2(-1, 0));
            if (keys.engineering_repair_crew_right.getDown())
                my_player_info->commandCrewSetTargetPosition(selected_crew_member, glm::ivec2(ic->position + glm::vec2(0.5, 0.5)) + glm::ivec2(1, 0));
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

GuiShipCrew::GuiShipCrew(GuiContainer* owner, string id, sp::ecs::Entity crew, sp::ecs::Entity& selected_crew_member, func_t func)
: GuiElement(owner, id), crew(crew), selected_crew_member(selected_crew_member), func(func)
{
}

void GuiShipCrew::onDraw(sp::RenderTarget& renderer)
{
    auto ic = crew.getComponent<InternalCrew>();
    if (!ic) return;

    setPosition(ic->position * getSize().x, sp::Alignment::TopLeft);

    float rotation = 0;
    string tex = "topdownCrew0.png";
    if (ic->action == InternalCrew::Action::Move)
        tex = "topdownCrew" + string(int(ic->action_delay * 12) % 6) + ".png";
    switch(ic->direction)
    {
    case InternalCrew::Direction::Left: rotation = 180; break;
    case InternalCrew::Direction::Right: rotation = 0; break;
    case InternalCrew::Direction::None:
    case InternalCrew::Direction::Up: rotation = -90; break;
    case InternalCrew::Direction::Down: rotation = 90; break;
    }
    renderer.drawRotatedSprite(tex, getCenterPoint(), getSize().x, rotation);
    if (selected_crew_member == crew)
        renderer.drawSprite("redicule.png", getCenterPoint(), getSize().x);
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
