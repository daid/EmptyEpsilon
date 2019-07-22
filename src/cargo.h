#ifndef CARGO_H
#define CARGO_H

#include "P.h"
#include "engine.h"
class Cargo;
#include "spaceObjects/spaceshipParts/dock.h"

class ModelData;

class Cargo : public MultiplayerObject
{
public:
  typedef std::vector<std::tuple<string, string, string>> Entries;

private:
  float heat;
  float energy_level;

public:
  Cargo(string multiplayerClassIdentifier);
  
  virtual Entries getEntries();
  virtual float getEnergy() { return energy_level; }
  virtual void setEnergy(float amount) { this->energy_level = amount; }
  virtual float getHeat() { return heat; }
  virtual void setHeat(float amount) { this->heat = amount; }
  virtual float getHealth() = 0;
  virtual void addHealth(float amount) = 0;

  virtual float getMinEnergy() { return 0; }
  virtual float getMaxEnergy() = 0;
  virtual float getMaxHealth() = 0;
  virtual P<ModelData> getModel() = 0;
  virtual bool onLaunch(Dock &source) = 0;
};
#endif //CARGO_H
