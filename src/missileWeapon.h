#ifndef MISSILE_WEAPON_H
#define MISSILE_WEAPON_H

#include "spaceObject.h"

/* Base class for all the missile weapons. Handles missile generic stuff like targeting, lifetime, etc... */
class MissileWeapon : public SpaceObject, public Updatable
{
    float speed; //meter/sec
    float turnrate; //deg/sec
    
    float lifetime; //sec
    sf::Color color;
    
    bool launch_sound_played;
public:
    P<SpaceObject> owner; //Only valid on server.
    int32_t target_id;

    MissileWeapon(string multiplayerName, float speed, float turnrate, float lifetime, sf::Color color);

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual void collision(Collisionable* target);
    virtual void takeDamage(float damageAmount, DamageInfo& info) { if (info.type != DT_Kinetic) destroy(); }
    
    //Called when the missile hits something (could be the target, or something else). Missile is destroyed afterwards.
    virtual void hitObject(P<SpaceObject> object) = 0;
    //Called when the missile's lifetime is up. Missile is destroyed afterwards.
    virtual void lifeEnded() {}
};

#endif//MISSILE_WEAPON_H
