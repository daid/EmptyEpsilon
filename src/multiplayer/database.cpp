#include "multiplayer/database.h"
#include "multiplayer.h"


namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const Database::KeyValue& kv) { return packet << kv.key << kv.value; }
    static inline DataBuffer& operator >> (DataBuffer& packet, Database::KeyValue& kv) { packet >> kv.key >> kv.value; return packet; }
}


BASIC_REPLICATION_IMPL(DatabaseReplication, Database)
    BASIC_REPLICATION_FIELD(parent);

    BASIC_REPLICATION_FIELD(name);
    REPLICATE_VECTOR_IF_DIRTY(key_values, key_values_dirty);
    BASIC_REPLICATION_FIELD(description);
    BASIC_REPLICATION_FIELD(image);
}