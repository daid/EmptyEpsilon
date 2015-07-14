#ifndef BEAM_EFFECT_H
#define BEAM_EFFECT_H

#include "spaceObject.h"

class BeamEffect : public SpaceObject, public Updatable
{
    float lifetime;
    int32_t sourceId;
    int32_t target_id;
    sf::Vector3f sourceOffset;
    sf::Vector3f targetOffset;
    sf::Vector2f targetLocation;
    sf::Vector3f hitNormal;
public:
    BeamEffect();

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent();
#endif
    virtual void update(float delta);

    void setSource(P<SpaceObject> source, sf::Vector3f offset);
    void setTarget(P<SpaceObject> target, sf::Vector2f hitLocation);
};

#endif//BEAM_EFFECT_H
