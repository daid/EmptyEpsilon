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

string crewPositionToString(CrewPosition value);
bool tryParseCrewPosition(string value, CrewPosition& result);

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

    class Iterator {
    public:
        Iterator(uint64_t _mask, CrewPosition _cp) : mask(_mask), cp(_cp) {
            if(cp != CrewPosition::MAX && (mask & (1 << int(cp))) == 0) {
                ++(*this);
            }
        }
        bool operator!=(const Iterator& other) const { return cp != other.cp; }
        void operator++() {
            cp = CrewPosition(int(cp)+1);
            while(cp != CrewPosition::MAX && (mask & (1 << int(cp))) == 0) {
                cp = CrewPosition(int(cp)+1);
            }
        }
        CrewPosition operator*() { return cp; }
    private:
        uint64_t mask;
        CrewPosition cp;
    };
    Iterator begin() { return {mask, CrewPosition(0)}; }
    Iterator end() { return {mask, CrewPosition::MAX}; }

    static CrewPositions all() { return CrewPositions{(1 << int(CrewPosition::MAX)) - 1}; }
};

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const CrewPositions& cps) { packet << cps.mask; return packet;}
    static inline DataBuffer& operator >> (DataBuffer& packet, CrewPositions& cps) { packet >> cps.mask; return packet; }
}
