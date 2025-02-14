#include "multiplayer/coolant.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(CoolantReplication, Coolant)
    BASIC_REPLICATION_FIELD(max);
    BASIC_REPLICATION_FIELD(max_coolant_per_system);
    BASIC_REPLICATION_FIELD(auto_levels);
}