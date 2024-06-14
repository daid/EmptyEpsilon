#include "multiplayer/moveto.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(MoveToReplication, MoveTo)
    BASIC_REPLICATION_FIELD(speed);
    BASIC_REPLICATION_FIELD(target);
}
