#ifndef MUSIC_H
#define MUSIC_H

#include "stringImproved.h"
#include "threatLevelEstimate.h"

class Music
{
private:
    P<ThreatLevelEstimate> threat_estimate;
    string music_file;
    bool music_enabled;
    bool threat_set_enabled;
public:
    Music(bool enabled);

    virtual void play(string music_file);
    virtual void playSet(string music_files);
    virtual void stop();
    virtual void enableThreatSet();
    virtual void disableThreatSet();
};

#endif//MUSIC_H
