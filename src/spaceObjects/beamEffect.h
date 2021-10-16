#ifndef BEAM_EFFECT_H
#define BEAM_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"

class BeamEffect : public SpaceObject, public Updatable
{
    float lifetime;
    int32_t sourceId;
    int32_t target_id;
    glm::vec3 sourceOffset{};
    glm::vec3 targetOffset{};
    glm::vec2 targetLocation{};
    glm::vec3 hitNormal{};
public:
    bool fire_ring;
    string beam_texture;
    string beam_fire_sound;
    float beam_fire_sound_power;
    BeamEffect();
    virtual ~BeamEffect();

    virtual void draw3DTransparent() override;
    virtual void update(float delta) override;

    void setSource(P<SpaceObject> source, glm::vec3 offset);
    void setTarget(P<SpaceObject> target, glm::vec2 hitLocation);

    ///Set the texture used for this beam. Default is texture/beam_orange.png
    void setTexture(string texture) {this->beam_texture = texture;}
    ///Set the sound played when firing the beam. Default firing sound is sfx/laser_fire.wav
    void setBeamFireSound(string sound) {this->beam_fire_sound = sound;}
    ///Control volume and pitch of firing sound. Default is 1.0, ships use beam damage/6
    void setBeamFireSoundPower(float power) {this->beam_fire_sound_power = power;}
    ///Control Duration of the beam. Default is 1 second
    void setDuration(float duration) {this->lifetime = duration;}
    void setRing(bool ring) {this->fire_ring = ring;}
protected:
    glm::mat4 getModelMatrix() const override;
    bool beam_sound_played;
};

#endif//BEAM_EFFECT_H
