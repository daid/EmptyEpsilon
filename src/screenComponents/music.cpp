#include "music.h"

Music::Music(bool enabled)
{
    music_enabled = enabled;
    threat_set_enabled = false;
    threat_estimate = new ThreatLevelEstimate();
}

void Music::play(string music_file)
{
    // Play the new song.
    if (music_enabled)
    {
        try {
            soundManager->playMusic(music_file);
        } catch (...) {
            LOG(WARNING) << "Failed to play " << music_file;
        }
    }
}

void Music::playSet(string music_files)
{
    // Play the new set of songs.
    if (music_enabled)
    {
        try {
            soundManager->playMusicSet(findResources(music_files));
        } catch (...) {
            LOG(WARNING) << "Failed to play " << music_files;
        }
    }
}

void Music::stop()
{
    soundManager->stopMusic();
}

void Music::enableThreatSet()
{
    if (!threat_set_enabled)
    {
        // Handle threat level change events.
        threat_estimate->setCallbacks([this](){
            // Low threat function
            LOG(INFO) << "Switching to ambient music";
            this->playSet("music/ambient/*.ogg");
        }, [this]() {
            // High threat function
            LOG(INFO) << "Switching to combat music";
            this->playSet("music/combat/*.ogg");
        });
        threat_set_enabled = true;
    }
}

void Music::disableThreatSet()
{
    // Disable threat level change event handling.
    threat_estimate->setCallbacks([this](){}, [this]() {});
    threat_set_enabled = false;
}
