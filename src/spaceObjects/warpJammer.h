#ifndef WARP_JAMMER_H
#define WARP_JAMMER_H

#include "spaceObject.h"

class WarpJammerObject : public SpaceObject
{
public:
    WarpJammerObject();
    ~WarpJammerObject();

    void setRange(float range) { } //TODO
    float getRange() { return 7000.0; } //TODO

    void setHull(float hull) { } //TODO
    float getHull() { return 1.0; } //TODO

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual bool canBeTargetedBy(sp::ecs::Entity other)  override { return true; }

    void onTakingDamage(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);

    virtual string getExportLine() override;
};

#endif//WARP_JAMMER_H
