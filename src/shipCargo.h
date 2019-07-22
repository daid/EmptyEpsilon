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
private:
  float hull_strength;
  float systems_health[SYS_COUNT];
public:
  ShipCargo();
  ShipCargo(P<ShipTemplate> ship_template);
  ShipCargo(P<SpaceShip> cargo);

  Cargo::Entries getEntries();
  string getCallSign() { return callsign; }
  P<ShipTemplate> getTemplate() { return ShipTemplate::getTemplate(template_name); }
  float getMaxEnergy() { return getTemplate()->energy_storage_amount; }
  float getMaxHealth() { return getTemplate()->hull * (SYS_COUNT + 1); }
  float getHealth();
  void addHealth(float amount);
  P<ModelData> getModel();
  bool onLaunch(Dock &source);
};

#endif //SHIP_CARGO_H
