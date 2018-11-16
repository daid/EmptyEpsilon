#include "shipCargo.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "gameGlobalInfo.h"

REGISTER_MULTIPLAYER_CLASS(ShipCargo, "ShipCargo");

ShipCargo::ShipCargo() : Cargo("ShipCargo")
{
    registerMemberReplication(&callsign);
    registerMemberReplication(&template_name);
    registerMemberReplication(&energy_level);
}

ShipCargo::ShipCargo(P<ShipTemplate> ship_template) : ShipCargo()
{
    this->template_name = ship_template->getName();
    this->callsign = "DRN-" + gameGlobalInfo->getNextShipCallsign();
    this->energy_level = ship_template->energy_storage_amount;
}

ShipCargo::ShipCargo(P<SpaceShip> cargo) : ShipCargo()
{
    this->template_name = cargo->template_name;
    this->callsign = cargo->callsign;
    this->energy_level = cargo->energy_level;
}

P<ModelData> ShipCargo::getModel()
{
    P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
    if (ship_template)
    {
        return ship_template->model_data;
    }
    else
        return nullptr;
}
bool ShipCargo::onLaunch(sf::Vector2f position, float rotationAngle)
{
    if (game_server)
    {
        P<PlayerSpaceship> drone = new PlayerSpaceship();
        if (drone)
        {
            drone->setTemplate(template_name);
            drone->setCallSign(callsign);
            drone->setEnergyLevel(energy_level);
            drone->setPosition(position);
            drone->setRotation(rotationAngle);
            drone->impulse_request = 0.5;
            return true;
        }
    }
    return false;
}

Cargo::Entries ShipCargo::getEntries()
{
    Cargo::Entries result;
    result.push_back(std::make_tuple("callsign", callsign));
    result.push_back(std::make_tuple("type", template_name));
    result.push_back(std::make_tuple("energy", int(energy_level)));
    return result;
}