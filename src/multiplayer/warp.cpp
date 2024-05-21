#include "multiplayer/warp.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(WarpDriveReplication, WarpDrive)
    BASIC_REPLICATION_FIELD(max_level);
    BASIC_REPLICATION_FIELD(speed_per_level);
    BASIC_REPLICATION_FIELD(energy_warp_per_second);
    BASIC_REPLICATION_FIELD(request);
    BASIC_REPLICATION_FIELD(current);
}

BASIC_REPLICATION_IMPL(WarpJammerReplication, WarpJammer)
    BASIC_REPLICATION_FIELD(range);
}
