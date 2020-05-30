#ifndef CARGO_H
#define CARGO_H

#include "P.h"
#include "engine.h"
#include "spaceObjects/spaceshipParts/dock.h"

class Dock;
class ModelData;


class Cargo : public MultiplayerObject
{
private:
  float energy_level;
  float heat;
  string callsign;
  int weapon_storage[MW_Count];
  int weapon_storage_max[MW_Count];

public:
  Cargo(string multiplayerClassIdentifier);
  
  typedef std::vector<std::tuple<string, string, string>> Entries;
  virtual Entries getEntries();
  virtual string getCallSign() { return callsign; }
  virtual float getEnergy() { return energy_level; }
  virtual void setEnergy(float amount) { this->energy_level = amount; }
  virtual float getHeat() { return heat; }
  virtual void setHeat(float amount) { this->heat = amount; }
  virtual float getHealth() = 0;
  virtual void addHealth(float amount) = 0;

  virtual int getWeaponStorage(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage[weapon]; }
  virtual int getWeaponStorageMax(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage_max[weapon]; }
  virtual void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage[weapon] = amount; }
  virtual void setWeaponStorageMax(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage_max[weapon] = amount; weapon_storage[weapon] = std::min(int(weapon_storage[weapon]), amount); }

  virtual float getMinEnergy() { return 0; }
  virtual float getMaxEnergy() = 0;
  virtual float getMaxHealth() = 0;
  virtual P<ModelData> getModel() = 0;
  virtual bool onLaunch(Dock &source) = 0;
};
#endif //CARGO_H
