#ifndef SHIP_INTERNAL_VIEW_H
#define SHIP_INTERNAL_VIEW_H

#include "gui/gui2_element.h"

class RepairCrew;
class GuiShipRoomContainer;
class GuiShipCrew;
class GuiThemeStyle;

class GuiShipInternalView : public GuiElement
{
private:
    sp::ecs::Entity viewing_ship;
    float room_size;
    GuiShipRoomContainer* room_container;
    sp::ecs::Entity selected_crew_member;
    std::vector<GuiShipCrew*> crew_list;
public:
    GuiShipInternalView(GuiContainer* owner, string id, float room_size);

    GuiShipInternalView* setShip(sp::ecs::Entity ship);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

class GuiShipRoomContainer : public GuiElement
{
public:
    typedef std::function<void(glm::ivec2 room_position)> func_t;
private:
    float room_size;
    func_t func;
public:
    GuiShipRoomContainer(GuiContainer* owner, string id, float room_size, func_t func);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

class GuiShipRoom : public GuiElement
{
public:
    typedef std::function<void(glm::ivec2 room_position)> func_t;
private:
    sp::ecs::Entity ship;
    ShipSystem::Type system;
    float room_size;
    func_t func;
    const GuiThemeStyle* room_theme;
public:
    GuiShipRoom(GuiContainer* owner, string id, float room_size, glm::ivec2 room_dimensions, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiShipRoom* setSystem(sp::ecs::Entity ship, ShipSystem::Type system) { this->ship = ship; this->system = system; return this; }

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

class GuiShipDoor : public GuiElement
{
public:
    typedef std::function<void()> func_t;

private:
    bool horizontal;
    func_t func;
    const GuiThemeStyle* door_theme;
public:
    GuiShipDoor(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiShipDoor* setHorizontal() { horizontal = true; return this; }

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

class GuiShipCrew : public GuiElement
{
public:
    typedef std::function<void(sp::ecs::Entity crew_member)> func_t;

    sp::ecs::Entity crew;
private:
    sp::ecs::Entity& selected_crew_member;
    func_t func;
    const GuiThemeStyle* crew_theme;
    const GuiThemeStyle* selection_theme;
public:
    GuiShipCrew(GuiContainer* owner, string id, sp::ecs::Entity crew, sp::ecs::Entity& selected_crew_member, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//SHIP_INTERNAL_VIEW_H
