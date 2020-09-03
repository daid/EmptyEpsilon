#ifndef DISCORD_H
#define DISCORD_H

#include "Updatable.h"

class DiscordRichPresence : public Updatable
{
public:
    DiscordRichPresence();

    void update(float delta) override;

private:
    float updateDelay = 0.0f;
};

#endif//DISCORD_H
