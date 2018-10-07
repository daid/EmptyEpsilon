#ifndef DRONE_H
#define DRONE_H

#include "P.h"
#include "shipTemplate.h"
#include "SFML/System/NonCopyable.hpp"

enum EDockType
{
    Launcher,
    Energy,
    Disabled
};
string getDockTypeName(EDockType dockType);

class SpaceShip;

enum EDockState
{
    Empty,
    // Docking,
    // Launching,
    Docked,
    MovingIn,
    MovingOut
};
string getDockStateName(EDockState state);

class Dock : public sf::NonCopyable
{
    constexpr static float combat_maneuver_charge_time = 20.0f; /*< Amount of time it takes to fully charge the combat maneuver system */

  protected:
    P<ShipTemplate> ship_template;
    SpaceShip *parent;
    int index_at_parent;

  public:
    EDockType dock_type;
    EDockState state;
    float move_speed;
    float current_distance;
    string callsign;
    string template_name;
    float energy_request;
    float energy_level;
    int move_target_index;
    Dock();

    void empty();
    void dock(SpaceShip *ship);
    void startMoveCargo();
    void cancelMoveCargo();
    bool isOpenForDocking();
    bool isUnoccupied();
    void update(float delta);
    void setParent(SpaceShip *parent);

    void setState(EDockState state) { this->state = state; }
    void setDockType(EDockType dockType) { this->dock_type = dockType; }
    void setIndex(int index) { this->index_at_parent = index; }
    void setCallSign(string new_callsign) { this->callsign = new_callsign; }
    string getCallSign() { return callsign; }
    void setTemplate(string template_name);
    float getEnergy() { return energy_level; }
    void setEnergy(float amount)
    {
        if ((amount > 0.0) && (amount <= ship_template->energy_storage_amount))
        {
            this->energy_level = amount;
        }
    }

    float getEnergyRequest() { return energy_request; }
    void setEnergyRequest(float amount)
    {
        if ((amount >= 0.0) && (amount <= ship_template->energy_storage_amount))
        {
            this->energy_request = amount;
        }
    }
    void setMoveTarget(int index)
    {
        move_target_index = index;
    }

    float getLoadTimeConfig();
    void setLoadTimeConfig(float load_time);

    bool operator==(const Dock &other);
};

#endif //DRONE_H
