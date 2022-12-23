#ifndef WARP_JAMMER_H
#define WARP_JAMMER_H

#include "spaceObject.h"

class WarpJammer : public SpaceObject
{
    static PVector<WarpJammer> jammer_list;

    float range;
public:
    WarpJammer();
    ~WarpJammer();

    void setRange(float range) { this->range = range; }
    float getRange() { return range; }

    void setHull(float hull) { } //TODO
    float getHull() { return 1.0; } //TODO

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual bool canBeTargetedBy(P<SpaceObject> other)  override { return true; }

    static bool isWarpJammed(glm::vec2 position);
    static glm::vec2 getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end);

    void onTakingDamage(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);

    virtual string getExportLine() override;
};

#endif//WARP_JAMMER_H
