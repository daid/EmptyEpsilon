#include "multiplayer/comms.h"
#include "multiplayer.h"


namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const CommsTransmitter::ScriptReply& r) { return packet << r.message; } \
    static inline DataBuffer& operator >> (DataBuffer& packet, CommsTransmitter::ScriptReply& r) { packet >> r.message; return packet; }
}


EMPTY_REPLICATION_IMPL(CommsReceiverReplication, CommsReceiver)
BASIC_REPLICATION_IMPL(CommsTransmitterReplication, CommsTransmitter)
    BASIC_REPLICATION_FIELD(state);
    BASIC_REPLICATION_FIELD(open_delay);
    BASIC_REPLICATION_FIELD(target_name);
    BASIC_REPLICATION_FIELD(incomming_message);
    REPLICATE_VECTOR_IF_DIRTY(script_replies, script_replies_dirty);
}
