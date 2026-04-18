#include "multiplayer/player.h"
#include "multiplayer.h"

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const Waypoints::Point& p) { return packet << p.id << p.set_id << p.position; }
    static inline DataBuffer& operator >> (DataBuffer& packet, Waypoints::Point& p) { packet >> p.id >> p.set_id >> p.position; return packet; }

    static inline DataBuffer& operator << (DataBuffer& packet, const std::array<bool, Waypoints::MAX_SETS>& arr)
    {
        uint8_t bits = 0;
        for (int i = 0; i < Waypoints::MAX_SETS; i++)
            if (arr[i]) bits |= (1 << i);
        return packet << bits;
    }
    static inline DataBuffer& operator >> (DataBuffer& packet, std::array<bool, Waypoints::MAX_SETS>& arr)
    {
        uint8_t bits;
        packet >> bits;
        for (int i = 0; i < Waypoints::MAX_SETS; i++)
            arr[i] = (bits >> i) & 1;
        return packet;
    }
}


BASIC_REPLICATION_IMPL(PlayerControlReplication, PlayerControl)
    BASIC_REPLICATION_FIELD(main_screen_setting);
    BASIC_REPLICATION_FIELD(main_screen_overlay);
    BASIC_REPLICATION_FIELD(alert_level);

    BASIC_REPLICATION_FIELD(control_code); //TODO: Instead of replicating this to clients, check it on receiving the commandSetShip in playerinfo
    BASIC_REPLICATION_FIELD(allowed_positions.mask);
}

BASIC_REPLICATION_IMPL(WaypointsReplication, Waypoints)
    REPLICATE_VECTOR_IF_DIRTY(waypoints, dirty);
    BASIC_REPLICATION_FIELD(is_route);
}
