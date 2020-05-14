#ifndef SUPPLY_DROP_H
#define SUPPLY_DROP_H

#include "spaceObject.h"
#include "shipTemplate.h"

class SupplyDrop : public SpaceObject
{
private:
    ScriptSimpleCallback on_pickup_callback;
public:
    int8_t weapon_storage[MW_Count];
    float energy;

    SupplyDrop();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    virtual void collide(Collisionable* target, float force) override;

    void setEnergy(float amount); 
    void setWeaponStorage(EMissileWeapons weapon, int amount);

    void onPickUp(ScriptSimpleCallback callback);

    virtual string getExportLine() override;
};

#endif//SUPPLY_DROP_H
