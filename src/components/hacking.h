#pragma once

// Component to indicate that this entity can hack other entities.
class HackingDevice
{
public:
    float effectiveness = 0.5f;
};

// Component on hackable entities to store any per-entity overrides for
// difficulty and hacking minigame type.
class HackingTarget
{
public:
    // Difficulty values map to the global range (0-3). A value of -1 uses the
    // global hacking_difficulty instead.
    int difficulty = -1;
    // Maps to an EHackingGames value. Value of -1 uses global hacking_games
    // instead.
    int games = -1;
};