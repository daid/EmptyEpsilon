#ifndef DRONE_H
#define DRONE_H

#include "P.h"
#include "shipTemplate.h"
#include "cargo.h"
#include "SFML/System/NonCopyable.hpp"

enum EDockType
{
    Dock_Launcher,
    Dock_Energy,
    Dock_Thermic,
    Dock_Disabled
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
    public:
    static Dock* findOpenForDocking(Dock docks[], int size);
  protected:
    SpaceShip *parent;
    int index_at_parent;

  public:
    EDockType dock_type;
    EDockState state;
    float move_speed;
    float current_distance;
    float energy_request;
    int move_target_index;
    int32_t cargo_id;
    Dock();

    void empty();
    void dock(P<Cargo> cargo);
    P<Cargo> getCargo();
    void startMoveCargo();
    void cancelMoveCargo();
    bool isOpenForDocking();
    bool isUnoccupied();
    void update(float delta);
    void setParent(SpaceShip *parent);

    void setState(EDockState state) { this->state = state; }
    void setDockType(EDockType dockType) { this->dock_type = dockType; }
    void setIndex(int index) { this->index_at_parent = index; }
    void setCargo(int32_t cargo_id){this->cargo_id = cargo_id;}
    float getEnergyRequest() { return energy_request; }
    void setEnergyRequest(float amount){this->energy_request = amount;}
    void setMoveTarget(int index)
    {
        move_target_index = index;
    }

    float getLoadTimeConfig();
    void setLoadTimeConfig(float load_time);

    bool operator==(const Dock &other);
};

#endif //DRONE_H
