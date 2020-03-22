#include "impulseSound.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "preferenceManager.h"

ImpulseSound::ImpulseSound()
{
    impulse_sound_id = -1;
    impulse_sound_enabled = PreferencesManager::get("impulse_sound_enabled", "1") == "1";
    impulse_sound_volume = PreferencesManager::get("impulse_sound_volume", "50").toInt();

    // If defined, use this ship's impulse sound file.
    if (my_spaceship)
        impulse_sound_file = my_spaceship->impulse_sound_file;
    else
        impulse_sound_file = "sfx/engine.wav";

    // If we can play an impulse sound, do so.
    if (my_spaceship && impulse_sound_enabled && impulse_sound_volume > 0)
        play(impulse_sound_file);
}

void ImpulseSound::play(string sound_file)
{
#ifndef __ANDROID__
    // Play impulse sounds only on my ship.
    if (!my_spaceship)
        return;

    // If there's already an impulse sound, stop it.
    if (impulse_sound_id > -1)
        soundManager->stopSound(impulse_sound_id);

    // Play the new impulse sound and store its integer ID in the class.
    impulse_sound_id = soundManager->playSound(sound_file, 0.0f, 0.0f, true);
#endif
}

void ImpulseSound::stop()
{
    soundManager->stopSound(impulse_sound_id);
    impulse_sound_id = -1;
}

void ImpulseSound::update(float delta)
{
#ifndef __ANDROID__
    // Update only if an impulse sound is defined.
    if (impulse_sound_id > -1)
    {
        // Get whether the ship's impulse engines are functional.
        float impulse_ability = std::max(0.0f, std::min(my_spaceship->getSystemEffectiveness(SYS_Impulse), my_spaceship->getSystemPower(SYS_Impulse)));

        // If so, update their pitch and volume.
        if (impulse_ability > 0.0f)
        {
            soundManager->setSoundVolume(impulse_sound_id, (std::max(10.0f * impulse_ability, fabsf(my_spaceship->current_impulse) * 10.0f * std::max(0.1f, impulse_ability))) * (impulse_sound_volume / 100.0f));
            soundManager->setSoundPitch(impulse_sound_id, std::max(0.7f * impulse_ability, fabsf(my_spaceship->current_impulse) + 0.2f * std::max(0.1f, impulse_ability)));
        } else {
            // If not, silence the impulse sound.
            // TODO: Play an engine failure sound.
            soundManager->setSoundVolume(impulse_sound_id, 0.0f);
            soundManager->setSoundPitch(impulse_sound_id, 0.0f);
        }
    }
#endif
}
