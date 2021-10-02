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

    virtual void draw3D(const glm::mat4& object_view_matrix) override;

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual void collide(Collisionable* target, float force) override;

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "Asteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + ":setSize(" + string(getSize(),0) + ")"; }

protected:
    glm::mat4 getModelMatrix() const override;
};

class VisualAsteroid : public SpaceObject
{
public:
    float rotation_speed;
    float z;
    float size;
    int model_number;

    VisualAsteroid();

    virtual void draw3D(const glm::mat4& object_view_matrix) override;

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "VisualAsteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" ":setSize(" + string(getSize(),0) + ")"; }

protected:
    glm::mat4 getModelMatrix() const override;
};

#endif//ASTEROID_H
