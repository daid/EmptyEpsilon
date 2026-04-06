#include "multiplayer/hacking.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(HackingDeviceReplication, HackingDevice)
    BASIC_REPLICATION_FIELD(effectiveness);
}

BASIC_REPLICATION_IMPL(HackingTargetReplication, HackingTarget)
    BASIC_REPLICATION_FIELD(difficulty);
    BASIC_REPLICATION_FIELD(games);
}