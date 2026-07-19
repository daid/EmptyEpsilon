#include "multiplayer/maneuveringthrusters.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(ManeuveringThrustersReplication, ManeuveringThrusters)
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

    BASIC_REPLICATION_FIELD(speed);
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(rotation_request);
}

BASIC_REPLICATION_IMPL(CombatManeuveringThrustersReplication, CombatManeuveringThrusters)
    BASIC_REPLICATION_FIELD(charge_time);
    BASIC_REPLICATION_FIELD(charge);
    BASIC_REPLICATION_FIELD(boost.request);
    BASIC_REPLICATION_FIELD(boost.active);
    BASIC_REPLICATION_FIELD(boost.speed);
    BASIC_REPLICATION_FIELD(boost.max_time);
    BASIC_REPLICATION_FIELD(boost.heat_per_second);
    BASIC_REPLICATION_FIELD(strafe.request);
    BASIC_REPLICATION_FIELD(strafe.active);
    BASIC_REPLICATION_FIELD(strafe.speed);
    BASIC_REPLICATION_FIELD(strafe.max_time);
    BASIC_REPLICATION_FIELD(strafe.heat_per_second);
}
