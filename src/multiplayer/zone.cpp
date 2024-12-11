#include "multiplayer/zone.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(ZoneReplication, Zone)
    BASIC_REPLICATION_FIELD(color);
    BASIC_REPLICATION_FIELD(label);
    BASIC_REPLICATION_FIELD(label_offset);
    REPLICATE_VECTOR_IF_DIRTY(outline, zone_dirty);
    if (BRR == BasicReplicationRequest::Receive && (flags & (flag >> 1))) target.updateTriangles();
}
