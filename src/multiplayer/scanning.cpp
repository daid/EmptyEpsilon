#include "multiplayer/scanning.h"
#include "multiplayer.h"

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const ScanState::Entry& kv) {
        return packet << kv.faction << kv.state;
    }
    static inline DataBuffer& operator >> (DataBuffer& packet, ScanState::Entry& kv) {
        return packet >> kv.faction >> kv.state;
    }
}


BASIC_REPLICATION_IMPL(ScanStateReplication, ScanState)
    BASIC_REPLICATION_FIELD(allow_simple_scan);
    BASIC_REPLICATION_FIELD(complexity);
    BASIC_REPLICATION_FIELD(depth);

    REPLICATE_VECTOR_IF_DIRTY(per_faction, per_faction_dirty);
}

BASIC_REPLICATION_IMPL(ScienceDescriptionReplication, ScienceDescription)
    BASIC_REPLICATION_FIELD(not_scanned);
    BASIC_REPLICATION_FIELD(friend_or_foe_identified);
    BASIC_REPLICATION_FIELD(simple_scan);
    BASIC_REPLICATION_FIELD(full_scan);
}

BASIC_REPLICATION_IMPL(ScienceScannerReplication, ScienceScanner)
    BASIC_REPLICATION_FIELD(delay);
    BASIC_REPLICATION_FIELD(max_scanning_delay);
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(source);
}
