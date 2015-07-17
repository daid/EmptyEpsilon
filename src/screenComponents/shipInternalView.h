#ifndef GUI_SHIP_INTERNAL_VIEW_H
#define GUI_SHIP_INTERNAL_VIEW_H

#include "gui/gui2.h"
#include "spaceObjects/spaceship.h"

class RepairCrew;
class GuiShipRoomContainer;

class GuiShipInternalView : public GuiElement
{
private:
    P<SpaceShip> viewing_ship;
    float room_size;
    GuiShipRoomContainer* room_container;
    P<RepairCrew> selected_crew_member;
public:
    GuiShipInternalView(GuiContainer* owner, string id, float room_size);
    
    GuiShipInternalView* setShip(P<SpaceShip> ship);
    
    virtual void onDraw(sf::RenderTarget& window);
};

class GuiShipRoomContainer : public GuiElement
{
public:
    typedef std::function<void(sf::Vector2i room_position)> func_t;
private:
    float room_size;
    func_t func;
public:
    GuiShipRoomContainer(GuiContainer* owner, string id, float room_size, func_t func);
    
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
};

class GuiShipRoom : public GuiElement
{
public:
    typedef std::function<void(sf::Vector2i room_position)> func_t;
private:
    P<SpaceShip> ship;
    ESystem system;
    float room_size;
    func_t func;
public:
    GuiShipRoom(GuiContainer* owner, string id, float room_size, sf::Vector2i room_dimensions, func_t func);
    
    virtual void onDraw(sf::RenderTarget& window);
    
    GuiShipRoom* setSystem(P<SpaceShip> ship, ESystem system) { this->ship = ship; this->system = system; return this; }

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
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
    
    virtual void onDraw(sf::RenderTarget& window);
    
    GuiShipDoor* setHorizontal() { horizontal = true; return this; }

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
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
    
    virtual void onDraw(sf::RenderTarget& window);
    
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
};

#endif//GUI_SHIP_INTERNAL_VIEW_H
