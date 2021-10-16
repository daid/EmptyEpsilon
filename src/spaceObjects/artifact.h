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
    ScriptSimpleCallback on_collision_callback;
    ScriptSimpleCallback on_player_collision_callback;

    string radar_trace_icon;
    float radar_trace_scale;
    glm::u8vec4 radar_trace_color;
public:
    Artifact();

    virtual void update(float delta) override;

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual void collide(Collisionable* target, float force) override;

    void setModel(string name);
    void setSpin(float spin=0.0);
    void explode();
    void allowPickup(bool allow);

    void setRadarTraceIcon(string icon);
    void setRadarTraceScale(float scale);
    void setRadarTraceColor(int r, int g, int b) { radar_trace_color = glm::u8vec4(r, g, b, 255); }

    void onPickUp(ScriptSimpleCallback callback);
    // Consistent naming workaround
    void onPickup(ScriptSimpleCallback callback) { onPickUp(callback); }
    void onCollision(ScriptSimpleCallback callback);
    void onPlayerCollision(ScriptSimpleCallback callback);

    virtual string getExportLine() override;

protected:
    glm::mat4 getModelMatrix() const override;
};

#endif//ARTIFACT_H
