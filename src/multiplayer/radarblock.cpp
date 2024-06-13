#include "multiplayer/radarblock.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(RadarBlockReplication, RadarBlock)
    BASIC_REPLICATION_FIELD(range);
    BASIC_REPLICATION_FIELD(behind);
}

EMPTY_REPLICATION_IMPL(NeverRadarBlockedReplication, NeverRadarBlocked)
