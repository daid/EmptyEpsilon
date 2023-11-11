#ifndef STEAM_RICH_PRESENCE_H
#define STEAM_RICH_PRESENCE_H

#include "Updatable.h"
#include "dynamicLibrary.h"

class SteamRichPresence : public Updatable
{
public:
    explicit SteamRichPresence();
    ~SteamRichPresence();

    void update(float delta) override;

private:
    float updateDelay = 0.0f;
};

#endif//STEAM_RICH_PRESENCE_H
