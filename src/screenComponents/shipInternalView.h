#ifndef SHIP_INTERNAL_VIEW_H
#define SHIP_INTERNAL_VIEW_H

#include "gui/gui2_element.h"
#include "spaceObjects/spaceship.h"

class RepairCrew;
class GuiShipRoomContainer;
class GuiShipCrew;

class GuiShipInternalView : public GuiElement
{
private:
    P<SpaceShip> viewing_ship;
    float room_size;
    GuiShipRoomContainer* room_container;
    P<RepairCrew> selected_crew_member;
    std::vector<GuiShipCrew*> crew_list;
public:
    GuiShipInternalView(GuiContainer* owner, string id, float room_size);

    GuiShipInternalView* setShip(P<SpaceShip> ship);

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
    P<SpaceShip> ship;
    ESystem system;
    float room_size;
    func_t func;
public:
    GuiShipRoom(GuiContainer* owner, string id, float room_size, glm::ivec2 room_dimensions, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiShipRoom* setSystem(P<SpaceShip> ship, ESystem system) { this->ship = ship; this->system = system; return this; }

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
    typedef std::function<void(P<RepairCrew> crew_member)> func_t;

private:
    P<RepairCrew> crew;
    func_t func;
public:
    GuiShipCrew(GuiContainer* owner, string id, P<RepairCrew> crew, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//SHIP_INTERNAL_VIEW_H
