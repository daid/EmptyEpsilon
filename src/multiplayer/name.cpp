#include "multiplayer/name.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(CallSignReplication, CallSign)
    BASIC_REPLICATION_FIELD(callsign);
}

BASIC_REPLICATION_IMPL(TypeNameReplication, TypeName)
    BASIC_REPLICATION_FIELD(type_name);
    BASIC_REPLICATION_FIELD(localized);
}
