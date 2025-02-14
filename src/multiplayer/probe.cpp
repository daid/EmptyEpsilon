#include "multiplayer/probe.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(ScanProbeLauncherReplication, ScanProbeLauncher)
    BASIC_REPLICATION_FIELD(max);
    BASIC_REPLICATION_FIELD(stock);
}
