#ifndef SCAN_PROBE_H
#define SCAN_PROBE_H

#include "spaceObject.h"

class ScanProbe : public SpaceObject, public Updatable
{
private:
    constexpr static float probe_speed = 1000.0f;
    float lifetime;
    sf::Vector2f target_position;
public:
    int owner_id;

    ScriptSimpleCallback on_expiration;
    ScriptSimpleCallback on_destruction;

    ScanProbe();
    virtual ~ScanProbe();

    virtual void update(float delta) override;
    virtual bool canBeTargetedBy(P<SpaceObject> other) override;
    virtual void takeDamage(float damage_amount, DamageInfo info) override;
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    void setTarget(sf::Vector2f target) { target_position = target; }
    sf::Vector2f getTarget() { return target_position; }
    void setOwner(P<SpaceObject> owner);

    void onExpiration(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);
};

#endif//SCAN_PROBE_H
