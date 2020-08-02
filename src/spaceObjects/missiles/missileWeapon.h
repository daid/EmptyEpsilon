#ifndef MISSILE_WEAPON_H
#define MISSILE_WEAPON_H

#include "spaceObjects/spaceObject.h"

/* Base class for all the missile weapons. Handles missile generic stuff like targeting, lifetime, etc... */
class MissileWeapon : public SpaceObject, public Updatable
{
protected:
    const MissileWeaponData& data;

    float lifetime; //sec

    bool launch_sound_played;

public:
    P<SpaceObject> owner; //Only valid on server.
    int32_t target_id;
    float target_angle;
    // Damage modifier for this missile which indicates it's size. (eg; Missiles by fighters have a low modifier), missiles from
    // capital ships have a high modifier.
    float category_modifier;

    MissileWeapon(string multiplayer_name, const MissileWeaponData& data);

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void update(float delta) override;

    virtual void collide(Collisionable* target, float force) override;
    virtual void takeDamage(float damage_amount, DamageInfo info) override {
        // Energy and EMP damage can destroy a missile.
        if (info.type != DT_Kinetic) destroy();
    }

    //Called when the missile hits something (could be the target, or something else). Missile is destroyed afterwards.
    virtual void hitObject(P<SpaceObject> object) = 0;
    //Called when the missile's lifetime is up. Missile is destroyed afterwards.
    virtual void lifeEnded() {}

private:
    void updateMovement();
};

#endif//MISSILE_WEAPON_H
