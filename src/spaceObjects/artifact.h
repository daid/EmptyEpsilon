#ifndef ARTIFACT_H
#define ARTIFACT_H

#include "spaceObject.h"

class Artifact : public SpaceObject, public Updatable
{
private:
    string current_model_data_name;
    string model_data_name;
    bool allow_pickup;
public:
    Artifact();

    virtual void update(float delta);

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual void collide(Collisionable* target);
    
    virtual bool canBeTargeted() { return true; }
    
    void setModel(string name);
    void explode();
    void allowPickup(bool allow);
};

#endif//ARTIFACT_H
