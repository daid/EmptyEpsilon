#ifndef ASTEROID_H
#define ASTEROID_H

#include "spaceObject.h"

class Asteroid : public SpaceObject
{
public:
    float rotation_speed;
    float z;
    float size;
    int model_number;

    Asteroid();

    virtual void draw3D() override;

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    virtual std::unordered_map<string, string> getGMInfo() override;

    virtual void collide(Collisionable* target, float force) override;

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "Asteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + ":setSize(" + string(getSize(),0) + ")"; }
};

class VisualAsteroid : public SpaceObject
{
public:
    float rotation_speed;
    float z;
    float size;
    int model_number;

    VisualAsteroid();

    virtual void draw3D() override;

    virtual std::unordered_map<string, string> getGMInfo() override;

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "VisualAsteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" ":setSize(" + string(getSize(),0) + ")"; }
};

#endif//ASTEROID_H
