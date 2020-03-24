#ifndef MUSIC_H
#define MUSIC_H

#include "stringImproved.h"
#include "threatLevelEstimate.h"

class Music
{
private:
    P<ThreatLevelEstimate> threat_estimate;
    bool music_enabled;
    // float music_volume; // Music volume is set in main.cpp
    string music_file;
public:
    Music();

    virtual void play(string music_file);
    virtual void playSet(string music_files);
    virtual void stop();
    virtual void update(float delta);
};

#endif//MUSIC_H
