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
    string beam_texture;
    string beam_fire_sound;
    float beam_fire_sound_power;
    BeamEffect();

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent();
#endif
    virtual void update(float delta);

    void setSource(P<SpaceObject> source, sf::Vector3f offset);
    void setTarget(P<SpaceObject> target, sf::Vector2f hitLocation);

    ///Set the texture used for this beam. Options available by default take the form beam_color.png
    void setTexture(string texture) {this->beam_texture = texture;}
    ///Set the sound played when firing the beam. Included laser sound is laser.wav
    void setBeamFireSound(string sound) {this->beam_fire_sound = sound;}
    ///Control volume and pitch of firing sound
    void setBeamFireSoundPower(float power) {this->beam_fire_sound_power = power;}
    ///Control Duration of the beam. Default is 1 second
    void setDuration(float duration) {this->lifetime = duration;}
};

#endif//BEAM_EFFECT_H
