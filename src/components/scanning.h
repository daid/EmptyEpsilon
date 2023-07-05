#pragma once

#include "ecs/entity.h"
#include <vector>


class ScanState
{
public:
    enum class State {
        NotScanned,
        FriendOrFoeIdentified,
        SimpleScan,
        FullScan
    };
    struct Entry
    {
        sp::ecs::Entity faction;
        ScanState::State state;
    };

    /*!
     * Scan state per FactionInfo.
     * When the required faction is not in the vector, the scan state
     * is SS_NotScanned
     */
    std::vector<Entry> per_faction;

    bool allow_simple_scan = false; // Does the first scan go to a full scan or a simple scan.
    int complexity = -1; //Amount of bars each minigame has (-1 for default)
    int depth = -1;      //Amount of minigames that need to be finished (-1 for default)

    State getStateFor(sp::ecs::Entity entity);
    void setStateFor(sp::ecs::Entity entity, State state);
    State getStateForFaction(sp::ecs::Entity entity);
    void setStateForFaction(sp::ecs::Entity entity, State state);
};

class ScienceDescription
{
public:
    string not_scanned;
    string friend_of_foe_identified;
    string simple_scan;
    string full_scan;
};

class ScienceScanner
{
public:
    float delay = 0.0f; // When a delay based scan is done, this will count down.
    float max_scanning_delay = 6.0f;
    sp::ecs::Entity target;
};