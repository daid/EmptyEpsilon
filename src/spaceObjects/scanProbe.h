#ifndef SCAN_PROBE_H
#define SCAN_PROBE_H

#include "spaceObject.h"

class ScanProbe : public SpaceObject, public Updatable
{
private:
    // Probe flight speed; 1U/sec.
    float probe_speed;
    // Remaining lifetime in seconds.
    float lifetime;
    // Probe target coordinates.
    glm::vec2 target_position{0, 0};
    // Whether the probe has arrived to the target_position.
    bool has_arrived;
public:
    int owner_id;

    ScriptSimpleCallback on_arrival;
    ScriptSimpleCallback on_expiration;
    ScriptSimpleCallback on_destruction;

    ScanProbe();
    virtual ~ScanProbe();

    void setSpeed(float probe_speed);
    float getSpeed();
    void setLifetime(float lifetime);
    float getLifetime();

    virtual void update(float delta) override;
    virtual bool canBeTargetedBy(P<SpaceObject> other) override;
    virtual void takeDamage(float damage_amount, DamageInfo info) override;
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    bool hasArrived() { return has_arrived; }
    void setTarget(glm::vec2 target) { target_position = target; }
    glm::vec2 getTarget() { return target_position; }
    P<SpaceObject> getOwner() { return game_server->getObjectById(owner_id); }
    void setOwner(P<SpaceObject> owner);

    void onArrival(ScriptSimpleCallback callback);
    void onExpiration(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);
};

#endif//SCAN_PROBE_H
