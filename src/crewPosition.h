#pragma once

#include <stdint.h>
#include <io/dataBuffer.h>


enum class CrewPosition
{
    //6/5 player crew
    helmsOfficer,
    weaponsOfficer,
    engineering,
    scienceOfficer,
    relayOfficer,
    //4/3 player crew
    tacticalOfficer,    //helms+weapons-shields
    engineeringAdvanced,//engineering+shields
    operationsOfficer, //science+comms
    //1 player crew
    singlePilot,
    //extras
    damageControl,
    powerManagement,
    databaseView,
    altRelay,
    commsOnly,
    shipLog,

    MAX
};

static_assert(static_cast<int>(CrewPosition::MAX) <= 64);
class CrewPositions
{
public:
    void add(CrewPosition cp) { mask |= 1 << static_cast<int>(cp); }
    void remove(CrewPosition cp) { mask &=~(1 << static_cast<int>(cp)); }
    bool has(CrewPosition cp) const { return mask & (1 << static_cast<int>(cp)); }

    uint64_t mask = 0;

    bool operator==(const CrewPositions& other) { return mask == other.mask; }
    bool operator!=(const CrewPositions& other) { return mask != other.mask; }
};

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const CrewPositions& cps) { packet << cps.mask; return packet;}
    static inline DataBuffer& operator >> (DataBuffer& packet, CrewPositions& cps) { packet >> cps.mask; return packet; }
}