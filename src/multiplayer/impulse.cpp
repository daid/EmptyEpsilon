#include "multiplayer/impulse.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(ImpulseEngineReplication, ImpulseEngine)
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

    BASIC_REPLICATION_FIELD(max_speed_forward);
    BASIC_REPLICATION_FIELD(max_speed_reverse);
    BASIC_REPLICATION_FIELD(acceleration_forward);
    BASIC_REPLICATION_FIELD(acceleration_reverse);
    BASIC_REPLICATION_FIELD(sound);
    BASIC_REPLICATION_FIELD(request);
    BASIC_REPLICATION_FIELD(actual);
}
