#include "multiplayer/orbit.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(OrbitReplication, Orbit)
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(center);
    BASIC_REPLICATION_FIELD(distance);
    BASIC_REPLICATION_FIELD(time);
}
