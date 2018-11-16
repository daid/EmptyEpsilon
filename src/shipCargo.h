#ifndef SHIP_CARGO_H
#define SHIP_CARGO_H

#include "P.h"
#include "shipTemplate.h"
#include "cargo.h"

class ShipTemplate;
class SpaceShip;

class ShipCargo : public Cargo
{
public:
  string callsign;
  string template_name;
  float energy_level;
  float hull_strength;
  
  ShipCargo();
  ShipCargo(P<ShipTemplate> ship_template);
  ShipCargo(P<SpaceShip> cargo);

  Cargo::Entries getEntries();
  string getCallSign() { return callsign; }
  P<ShipTemplate> getTemplate() { return ShipTemplate::getTemplate(template_name); }
  float getEnergy() { return energy_level; }
  float getMaxEnergy() { return getTemplate()->energy_storage_amount; }
  P<ModelData> getModel();
  void setEnergy(float amount) { this->energy_level = amount; }
  bool onLaunch(sf::Vector2f position, float rotationAngle);
};

#endif //SHIP_CARGO_H
