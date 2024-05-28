#include "multiplayer/gravity.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(GravityReplication, Gravity)
    BASIC_REPLICATION_FIELD(range);
    BASIC_REPLICATION_FIELD(force);
}