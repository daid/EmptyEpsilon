#include "multiplayer/internalrooms.h"
#include "multiplayer.h"

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const InternalRooms::Room& r) {
        return packet << r.position << r.size << r.system;
    }
    static inline DataBuffer& operator >> (DataBuffer& packet, InternalRooms::Room& r) {
        return packet >> r.position >> r.size >> r.system;
    }
    static inline DataBuffer& operator << (DataBuffer& packet, const InternalRooms::Door& d) {
        return packet << d.position << d.horizontal;
    }
    static inline DataBuffer& operator >> (DataBuffer& packet, InternalRooms::Door& d) {
        return packet >> d.position >> d.horizontal;
    }
}

BASIC_REPLICATION_IMPL(InternalRoomsReplication, InternalRooms)
    BASIC_REPLICATION_FIELD(auto_repair_enabled);
    REPLICATE_VECTOR_IF_DIRTY(rooms, rooms_dirty);
    REPLICATE_VECTOR_IF_DIRTY(doors, doors_dirty);
}

BASIC_REPLICATION_IMPL(InternalCrewReplication, InternalCrew)
    BASIC_REPLICATION_FIELD(move_speed);
    BASIC_REPLICATION_FIELD(position);
    BASIC_REPLICATION_FIELD(target_position);
    BASIC_REPLICATION_FIELD(action);
    BASIC_REPLICATION_FIELD(direction);
    BASIC_REPLICATION_FIELD(ship);
}
