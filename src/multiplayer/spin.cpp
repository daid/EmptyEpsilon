#include "multiplayer/spin.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(SpinReplication, Spin)
    BASIC_REPLICATION_FIELD(rate);
}
