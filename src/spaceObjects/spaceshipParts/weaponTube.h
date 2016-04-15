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
    WTS_Unloading,
    WTS_Firing
};

class WeaponTube : public sf::NonCopyable
{
public:
    WeaponTube();

    void setParent(SpaceShip* parent);
    void setIndex(int index);

    float getLoadTimeConfig();
    void setLoadTimeConfig(float load_time);

    void setDirection(float direction);
    float getDirection();
    
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

    bool canLoad(EMissileWeapons type);
    void allowLoadOf(EMissileWeapons type);
    void disallowLoadOf(EMissileWeapons type);
    
    void forceUnload();
    
    void update(float delta);

    bool isEmpty();
    bool isLoaded();
    bool isLoading();
    bool isUnloading();
    bool isFiring();
    
    float getLoadProgress();
    float getUnloadProgress();

    EMissileWeapons getLoadType();

    //Calculate a possible firing solution towards the target for this missile tube.
    //Will return the angle that the missile needs to turn to to possibly hit this target.
    //Will return infinity when no solution is found.
    float calculateFiringSolution(P<SpaceObject> target);
private:
    SpaceShip* parent;
    int tube_index;
    
    //Configuration
    float load_time;
    uint32_t type_allowed_mask;
    float direction;

    //Runtime state
    EMissileWeapons type_loaded;
    EWeaponTubeState state;
    float delay;
    int fire_count;
};

#endif//WEAPON_TUBE_H
