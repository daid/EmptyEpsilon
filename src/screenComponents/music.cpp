#include "music.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "preferenceManager.h"

Music::Music()
{
    music_enabled = PreferencesManager::get("music_enabled", "1") == "1";
    // Music volume is set in main.cpp
    // music_volume = PreferencesManager::get("music_volume", "50").toInt();
    threat_estimate = new ThreatLevelEstimate();

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
}

void Music::play(string music_file)
{
    // Play the new song.
    if (music_enabled)
        soundManager->playMusic(music_file);
}

void Music::playSet(string music_files)
{
    // Play the new set of songs.
    if (music_enabled)
        soundManager->playMusicSet(findResources(music_files));
}

void Music::stop()
{
    soundManager->stopMusic();
}

void Music::update(float delta)
{
}
