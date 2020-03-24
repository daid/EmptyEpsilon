#ifndef MUSIC_H
#define MUSIC_H

#include "stringImproved.h"
#include "threatLevelEstimate.h"

class Music
{
private:
    P<ThreatLevelEstimate> threat_estimate;
    string music_file;
public:
    Music(bool enabled);

    virtual void play(string music_file, bool enabled);
    virtual void playSet(string music_files, bool enabled);
    virtual void stop();
};

#endif//MUSIC_H
