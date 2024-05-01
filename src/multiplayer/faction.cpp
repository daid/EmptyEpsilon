#include "multiplayer/faction.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(FactionReplication, Faction)
    BASIC_REPLICATION_FIELD(entity);
}
