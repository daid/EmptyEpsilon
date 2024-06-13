#include "multiplayer/target.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(TargetReplication, Target)
    BASIC_REPLICATION_FIELD(entity);
}
