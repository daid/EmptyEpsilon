#ifndef SUPPLY_DROP_H
#define SUPPLY_DROP_H

#include "spaceObject.h"
#include "shipTemplate.h"

class SupplyDrop : public SpaceObject
{
public:
    int8_t weapon_storage[MW_Count];
    float energy;

    SupplyDrop();

    virtual void draw3D();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual void collide(Collisionable* target);

    void setEnergy(float amount) { energy = amount; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon != MW_None) weapon_storage[weapon] = amount; }
};

#endif//ASTEROID_H

