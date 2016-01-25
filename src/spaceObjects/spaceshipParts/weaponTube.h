#ifndef WEAPON_TUBE_H
#define WEAPON_TUBE_H

#include "SFML/System/NonCopyable.hpp"
#include "shipTemplate.h"

class SpaceShip;

enum EWeaponTubeState
{
    WTS_Empty,
    WTS_Loading,
    WTS_Loaded,
    WTS_Unloading
};

class WeaponTube : public sf::NonCopyable
{
public:
    WeaponTube();

    void setParent(SpaceShip* parent);
    void setIndex(int index);
    
    /*!
     * Load a missile tube.
     * \param type Weapon type that is loaded.
     */
    void startLoad(EMissileWeapons type);
    void startUnload();
    /*!
     * Fire a missile tube.
     * \param target_angle Angle in degrees to where the missile needs to be shot.
     */
    void fire(float target_angle);
    
    void forceUnload();
    
    void update(float delta);

    bool isEmpty();
    bool isLoaded();
    bool isLoading();
    bool isUnloading();
    
    float getLoadProgress();
    float getUnloadProgress();

    EMissileWeapons getLoadType();

private:
    SpaceShip* parent;
    int tube_index;

    EMissileWeapons type_loaded;
    EWeaponTubeState state;
    float delay;
};

#endif//WEAPON_TUBE_H
