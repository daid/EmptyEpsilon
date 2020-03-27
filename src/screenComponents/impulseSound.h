#ifndef IMPULSE_SOUND_H
#define IMPULSE_SOUND_H

#include "stringImproved.h"

class ImpulseSound
{
private:
    int impulse_sound_id;
    bool impulse_sound_enabled;
    float impulse_sound_volume;
    string impulse_sound_file;
public:
    ImpulseSound(bool enabled);
    ~ImpulseSound();

    int getImpulseSoundID() { return impulse_sound_id; }

    virtual void play(string sound_file);
    virtual void stop();
    virtual void update(float delta);
};

#endif//IMPULSE_SOUND_H
