#include "multiplayer/player.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(PlayerControlReplication, PlayerControl)
    BASIC_REPLICATION_FIELD(main_screen_setting);
    BASIC_REPLICATION_FIELD(main_screen_overlay);
    BASIC_REPLICATION_FIELD(alert_level);

    BASIC_REPLICATION_FIELD(control_code); //TODO: Instead of replicating this to clients, check it on receiving the commandSetShip in playerinfo
    BASIC_REPLICATION_FIELD(allowed_positions.mask);
}
