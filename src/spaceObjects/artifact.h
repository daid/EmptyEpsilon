#ifndef ARTIFACT_H
#define ARTIFACT_H

#include "spaceObject.h"

class Artifact : public SpaceObject, public Updatable
{
private:
    string current_model_data_name;
    string model_data_name;
    float artifact_spin;
    bool allow_pickup;
    ScriptSimpleCallback on_pickup_callback;

    string radar_trace_icon;
    float radar_trace_scale;
    sf::Color radar_trace_color;

public:
    Artifact();

    virtual void update(float delta) override;

    virtual void draw3D() override;

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    virtual void collide(Collisionable* target, float force) override;

    void setModel(string name);
    void setSpin(float spin=0.0);
    void explode();
    void allowPickup(bool allow);

    void setRadarTraceIcon(string icon);
    void setRadarTraceScale(float scale);
    void setRadarTraceColor(int r, int g, int b) { radar_trace_color = sf::Color(r, g, b); }

    virtual string getExportLine() override;
    void onPickUp(ScriptSimpleCallback callback);
};

#endif//ARTIFACT_H
