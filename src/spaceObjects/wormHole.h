#ifndef WORM_HOLE_H
#define WORM_HOLE_H

#include "nebula.h"
#include "spaceObject.h"
#include "pathPlanner.h"

class WormHole : public SpaceObject, public Updatable
{
    sf::Vector2f target_position = sf::Vector2f(0.0f, 0.0f);
    float update_delta = 0.0f;
    P<PathPlannerManager>  pathPlanner;
    
    int radar_visual;
    static const int cloud_count = 5;
    NebulaCloud clouds[cloud_count];

    ScriptSimpleCallback on_teleportation;
public:
    WormHole();

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent() override;
#endif//FEATURE_3D_RENDERING
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void update(float delta) override;
    virtual void collide(Collisionable* target, float force) override;
    
    void setTargetPosition(sf::Vector2f v);   /* Where to jump to */
    sf::Vector2f getTargetPosition();
    void onTeleportation(ScriptSimpleCallback callback);

    virtual string getExportLine() override { return "WormHole():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + "):setTargetPosition(" + string(target_position.x, 0) + ", " + string(target_position.y, 0) + ")"; }
};

#endif//WORM_HOLE_H
