#ifndef ARTIFACT_H
#define ARTIFACT_H

#include "spaceObject.h"

class Artifact : public SpaceObject, public Updatable
{
private:
    string current_model_data_name;
    string model_data_name;
    float artifact_spin=0.0;
    bool allow_pickup;
    ScriptSimpleCallback on_pickup_callback;
public:
    Artifact();

    virtual void update(float delta);

    virtual void draw3D();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual void collide(Collisionable* target, float force) override;

    void setModel(string name);
    void setSpin(float spin=0.0);
    void explode();
    void allowPickup(bool allow);
    
    virtual string getExportLine();
    void onPickUp(ScriptSimpleCallback callback);
};

#endif//ARTIFACT_H
