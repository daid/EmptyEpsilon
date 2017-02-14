#ifndef MINE_H
#define MINE_H

#include "spaceObject.h"

class Mine : public SpaceObject, public Updatable
{
    constexpr static float blastRange = 1000.0f;
    constexpr static float trigger_range = 600.0f;
    constexpr static float triggerDelay = 1.0f;
    constexpr static float damageAtCenter = 160.0f;
    constexpr static float damageAtEdge = 30.0f;

public:
    P<SpaceObject> owner;
    bool triggered;       //Only valid on server.
    float triggerTimeout; //Only valid on server.
    float ejectTimeout;   //Only valid on server.
    float particleTimeout;

    Mine();

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);

    virtual void collide(Collisionable* target, float force);
    void eject();
    void explode();
    
    virtual string getExportLine() { return "Mine():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

private:
    const MissileWeaponData& data;
};

#endif//MINE_H
