#include "multiplayer/jumpdrive.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(JumpDriveReplication, JumpDrive)
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

    BASIC_REPLICATION_FIELD(min_distance);
    BASIC_REPLICATION_FIELD(max_distance);
    BASIC_REPLICATION_FIELD(charge);
    BASIC_REPLICATION_FIELD(distance);
    BASIC_REPLICATION_FIELD(delay);
    BASIC_REPLICATION_FIELD(just_jumped);
}
