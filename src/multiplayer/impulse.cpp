#include "multiplayer/impulse.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(ImpulseEngineReplication, ImpulseEngine)
    BASIC_REPLICATION_FIELD(max_speed_forward);
    BASIC_REPLICATION_FIELD(max_speed_reverse);
    BASIC_REPLICATION_FIELD(acceleration_forward);
    BASIC_REPLICATION_FIELD(acceleration_reverse);
    BASIC_REPLICATION_FIELD(sound);
    BASIC_REPLICATION_FIELD(request);
    BASIC_REPLICATION_FIELD(actual);
}
