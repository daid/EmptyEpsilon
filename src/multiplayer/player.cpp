#include "multiplayer/player.h"
#include "multiplayer.h"

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const Waypoints::Point& p) { return packet << p.id << p.position; }
    static inline DataBuffer& operator >> (DataBuffer& packet, Waypoints::Point& p) { packet >> p.id >> p.position; return packet; }
}


BASIC_REPLICATION_IMPL(PlayerControlReplication, PlayerControl)
    BASIC_REPLICATION_FIELD(main_screen_setting);
    BASIC_REPLICATION_FIELD(main_screen_overlay);
    BASIC_REPLICATION_FIELD(alert_level);

    BASIC_REPLICATION_FIELD(control_code); //TODO: Indstead of replicating this to clients, check it on receiving the commandSetShip in playerinfo
    BASIC_REPLICATION_FIELD(allowed_positions.mask);
    BASIC_REPLICATION_FIELD(in_gravity);
    BASIC_REPLICATION_FIELD(glitch_alpha);
    BASIC_REPLICATION_FIELD(glitch_alpha_decay_rate);
    BASIC_REPLICATION_FIELD(warp_alpha_decay_rate);
    BASIC_REPLICATION_FIELD(warp_alpha);

    BASIC_REPLICATION_FIELD(just_teleported);
}

BASIC_REPLICATION_IMPL(WaypointsReplication, Waypoints)
    REPLICATE_VECTOR_IF_DIRTY(waypoints, dirty);
}
