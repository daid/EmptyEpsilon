#include "multiplayer/hull.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(HullReplication, Hull)
    BASIC_REPLICATION_FIELD(current);
    BASIC_REPLICATION_FIELD(max);
    BASIC_REPLICATION_FIELD(damage_indicator);
}