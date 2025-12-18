#pragma once

#include <stringImproved.h>

class Sfx
{
public:
    string sound;
    float volume = 100.0f;
    float pitch = 1.0f;
    bool played = false;
};

/*
        if (be.source && delta > 0 && !beam_sound_played)
        {
            float volume = 50.0f + (beam_fire_sound_power * 75.0f);
            float pitch = (1.0f / beam_fire_sound_power) + random(-0.1f, 0.1f);
            if (source) {
                if (auto transform = source.getComponent<sp::Transform>())
                soundManager->playSound(beam_fire_sound, transform->getPosition(), 400.0, 0.6, pitch, volume);
            }
            beam_sound_played = true;
        }
*/