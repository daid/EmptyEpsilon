#ifndef WARP_JAMMER_H
#define WARP_JAMMER_H

#include "spaceObject.h"

class WarpJammer : public SpaceObject
{
    static PVector<WarpJammer> jammer_list;

    float range;
    float hull;

    ScriptSimpleCallback on_destruction;
    ScriptSimpleCallback on_taking_damage;
public:
    WarpJammer();
    ~WarpJammer();

    void setRange(float range) { this->range = range; }
    float getRange() { return range; }

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    virtual bool canBeTargetedBy(P<SpaceObject> other)  override { return true; }
    virtual void takeDamage(float damage_amount, DamageInfo info) override;

    static bool isWarpJammed(glm::vec2 position);
    static glm::vec2 getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end);

    void onTakingDamage(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);

    virtual string getExportLine() override;
};

#endif//WARP_JAMMER_H
