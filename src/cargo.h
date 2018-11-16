#ifndef CARGO_H
#define CARGO_H

#include "P.h"
#include "engine.h"

class ModelData;

class Cargo : public MultiplayerObject
{
public:
  typedef std::vector<std::tuple<string, string>> Entries;

public:
  Cargo(string multiplayerClassIdentifier) : MultiplayerObject(multiplayerClassIdentifier) {}
  virtual Entries getEntries() = 0;
  virtual float getEnergy() = 0;
  virtual float getMaxEnergy() = 0;
  virtual float getMinEnergy() { return 0; }
  virtual P<ModelData> getModel() = 0;
  virtual void setEnergy(float amount) = 0;
  virtual bool onLaunch(sf::Vector2f position, float rotationAngle) = 0;
};
#endif //CARGO_H
