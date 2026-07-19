#include "multiplayer/warp.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(WarpDriveReplication, WarpDrive)
    BASIC_REPLICATION_FIELD(health);
    BASIC_REPLICATION_FIELD(health_max);
    BASIC_REPLICATION_FIELD(power_level);
    BASIC_REPLICATION_FIELD(power_request);
    BASIC_REPLICATION_FIELD(heat_level);
    BASIC_REPLICATION_FIELD(coolant_level);
    BASIC_REPLICATION_FIELD(coolant_request);
    BASIC_REPLICATION_FIELD(can_be_hacked);
    BASIC_REPLICATION_FIELD(hacked_level);
    BASIC_REPLICATION_FIELD(power_factor);
    BASIC_REPLICATION_FIELD(coolant_change_rate_per_second);
    BASIC_REPLICATION_FIELD(heat_add_rate_per_second);
    BASIC_REPLICATION_FIELD(power_change_rate_per_second);
    BASIC_REPLICATION_FIELD(auto_repair_per_second);
    BASIC_REPLICATION_FIELD(damage_per_second_on_overheat);

    BASIC_REPLICATION_FIELD(charge_time);
    BASIC_REPLICATION_FIELD(decharge_time);
    BASIC_REPLICATION_FIELD(heat_per_warp);
    BASIC_REPLICATION_FIELD(max_level);
    BASIC_REPLICATION_FIELD(speed_per_level);
    BASIC_REPLICATION_FIELD(energy_warp_per_second);
    BASIC_REPLICATION_FIELD(request);
    BASIC_REPLICATION_FIELD(current);
}

BASIC_REPLICATION_IMPL(WarpJammerReplication, WarpJammer)
    BASIC_REPLICATION_FIELD(range);
}
