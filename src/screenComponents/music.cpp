#include "music.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "preferenceManager.h"

Music::Music(bool enabled)
{
    // Music volume is set in main.cpp
    threat_estimate = new ThreatLevelEstimate();

    // Handle threat level change events.
    threat_estimate->setCallbacks([this, enabled](){
        // Low threat function
        LOG(INFO) << "Switching to ambient music";
        this->playSet("music/ambient/*.ogg", enabled);
    }, [this, enabled]() {
        // High threat function
        LOG(INFO) << "Switching to combat music";
        this->playSet("music/combat/*.ogg", enabled);
    });
}

void Music::play(string music_file, bool enabled)
{
    // Play the new song.
    if (enabled)
        soundManager->playMusic(music_file);
}

void Music::playSet(string music_files, bool enabled)
{
    // Play the new set of songs.
    if (enabled)
        soundManager->playMusicSet(findResources(music_files));
}

void Music::stop()
{
    soundManager->stopMusic();
}
