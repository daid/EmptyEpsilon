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

    void play(string sound_file);
    void stop();
    void update(float delta);
};

#endif//IMPULSE_SOUND_H
