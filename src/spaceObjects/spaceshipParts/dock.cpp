#include "dock.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include <algorithm>

Dock::Dock() : parent(nullptr), dock_type(Disabled), move_target_index(-1)
{
    empty();
}

void Dock::startMoveCargo()
{
    if (move_target_index >= 0 && move_target_index < max_docks_count)
    {
        Dock &dest = parent->docks[move_target_index];
        if (dest.isOpenForDocking())
        {
            this->setState(EDockState::MovingOut);
            current_distance = 0;
            dest.template_name = template_name;
            dest.callsign = callsign;
            dest.energy_level = energy_level;
            dest.energy_request = energy_level;
            dest.setState(EDockState::MovingIn);
            dest.current_distance = 1;
            dest.move_target_index = index_at_parent;
        }
    }
}

void Dock::cancelMoveCargo()
{
    if (state == MovingOut)
    {
        state = MovingIn;
        Dock &dest = parent->docks[move_target_index];
        dest.state = MovingOut;
    }
}

void Dock::dock(SpaceShip *other)
{
    setTemplate(other->template_name);
    setCallSign(other->callsign);
    setEnergy(other->energy_level);
    setEnergyRequest(other->energy_level);
    setState(EDockState::Docked);
    current_distance = 0;
}

void Dock::empty()
{
    state = Empty;
    callsign = template_name = "";
    energy_request = energy_level = 0;
    current_distance = 1;
}

bool Dock::isUnoccupied()
{
    return dock_type != Disabled && state == Empty;
}

bool Dock::isOpenForDocking()
{
    return isUnoccupied();
}

void Dock::setParent(SpaceShip *parent)
{
    assert(!this->parent);
    this->parent = parent;

    parent->registerMemberReplication(&dock_type);
    parent->registerMemberReplication(&state);
    parent->registerMemberReplication(&callsign);
    parent->registerMemberReplication(&template_name);
    parent->registerMemberReplication(&energy_request);
    parent->registerMemberReplication(&energy_level);
    parent->registerMemberReplication(&move_target_index);
}

void Dock::setTemplate(string template_name)
{
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    this->template_name = template_name;
    ship_template = new_ship_template;
}

bool Dock::operator==(const Dock &other)
{
    if (state == other.state && state == EDockState::Empty)
        return true;
    return state == other.state && ship_template == other.ship_template && callsign == other.callsign && energy_level && other.energy_level;
}

void Dock::update(float delta)
{
    if (state == MovingOut)
    {
        float distanceDelta = delta * parent->getSystemEffectiveness(SYS_Docks) / SpaceShip::dock_move_time;
        current_distance += distanceDelta;
        Dock &dest = parent->docks[move_target_index];
        if (current_distance >= 1)
        {
            empty();
            dest.setState(Docked);
        }
        else
        {
            dest.current_distance = 1 - current_distance;
        }
    }
    else if (dock_type == Energy && state == Docked)
    {
        if (ship_template)
        {
            energy_request = std::min(energy_request, ship_template->energy_storage_amount);
        }
        energy_request = std::max(energy_request, 0.0f);

        float energyDelta = std::min(delta * this->parent->getSystemEffectiveness(SYS_Docks) *  PlayerSpaceship::energy_transfer_per_second, std::abs(energy_request - energy_level));
        if (energy_request > energy_level)
        {
            energyDelta = std::min(energyDelta, parent->energy_level);
            parent->energy_level -= energyDelta;
            energy_level += energyDelta;
        }
        else if (energy_request < energy_level)
        {
            energyDelta = std::min(energyDelta, std::max(0.0f, parent->max_energy_level - parent->energy_level));
            parent->energy_level += energyDelta;
            energy_level -= energyDelta;
        }
    }
}

string getDockStateName(EDockState state)
{
    switch (state)
    {
    case Empty:
        return "Empty";
    case Docked:
        return "Docked";
    case MovingIn:
        return "Moving in";
    case MovingOut:
        return "Moving out";
    default:
        return "Unknown";
    }
}

string getDockTypeName(EDockType dockType)
{
    switch (dockType)
    {
    case Launcher:
        return "Launcher";
    case Energy:
        return "Energy";
    default:
        return "Unknown";
    }
}