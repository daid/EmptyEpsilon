#include "multiplayer/selfdestruct.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(SelfDestructReplication, SelfDestruct)
    BASIC_REPLICATION_FIELD(active);
    BASIC_REPLICATION_FIELD(code[0]);
    BASIC_REPLICATION_FIELD(code[1]);
    BASIC_REPLICATION_FIELD(code[2]);
    BASIC_REPLICATION_FIELD(confirmed[0]);
    BASIC_REPLICATION_FIELD(confirmed[1]);
    BASIC_REPLICATION_FIELD(confirmed[2]);
    BASIC_REPLICATION_FIELD(entry_position[0]);
    BASIC_REPLICATION_FIELD(entry_position[1]);
    BASIC_REPLICATION_FIELD(entry_position[2]);
    BASIC_REPLICATION_FIELD(show_position[0]);
    BASIC_REPLICATION_FIELD(show_position[1]);
    BASIC_REPLICATION_FIELD(show_position[2]);
    BASIC_REPLICATION_FIELD(countdown);
}
