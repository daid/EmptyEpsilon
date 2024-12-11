#include "multiplayer/faction.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(FactionReplication, Faction)
    BASIC_REPLICATION_FIELD(entity);
}

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const FactionInfo::Relation& r) { return packet << r.other_faction << r.relation; } \
    static inline DataBuffer& operator >> (DataBuffer& packet, FactionInfo::Relation& r) { packet >> r.other_faction >> r.relation; return packet; }
}

BASIC_REPLICATION_IMPL(FactionInfoReplication, FactionInfo)
    BASIC_REPLICATION_FIELD(gm_color);
    BASIC_REPLICATION_FIELD(name);
    BASIC_REPLICATION_FIELD(locale_name);
    BASIC_REPLICATION_FIELD(description);
    BASIC_REPLICATION_FIELD(reputation_points);
    REPLICATE_VECTOR_IF_DIRTY(relations, relations_dirty);
}
