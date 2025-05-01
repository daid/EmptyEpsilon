#include "multiplayer/shields.h"
#include "multiplayer.h"

BASIC_REPLICATION_IMPL(ShieldsReplication, Shields)
    BASIC_REPLICATION_FIELD(front_system.health);
    BASIC_REPLICATION_FIELD(front_system.health_max);
    BASIC_REPLICATION_FIELD(front_system.power_level);
    BASIC_REPLICATION_FIELD(front_system.power_request);
    BASIC_REPLICATION_FIELD(front_system.heat_level);
    BASIC_REPLICATION_FIELD(front_system.coolant_level);
    BASIC_REPLICATION_FIELD(front_system.coolant_request);
    BASIC_REPLICATION_FIELD(front_system.can_be_hacked);
    BASIC_REPLICATION_FIELD(front_system.hacked_level);
    BASIC_REPLICATION_FIELD(front_system.power_factor);
    BASIC_REPLICATION_FIELD(front_system.coolant_change_rate_per_second);
    BASIC_REPLICATION_FIELD(front_system.heat_add_rate_per_second);
    BASIC_REPLICATION_FIELD(front_system.power_change_rate_per_second);
    BASIC_REPLICATION_FIELD(front_system.auto_repair_per_second);
    //BASIC_REPLICATION_FIELD(front_system.damage_per_second_on_overheat); TODO: see below

    BASIC_REPLICATION_FIELD(rear_system.health);
    BASIC_REPLICATION_FIELD(rear_system.health_max);
    BASIC_REPLICATION_FIELD(rear_system.power_level);
    BASIC_REPLICATION_FIELD(rear_system.power_request);
    BASIC_REPLICATION_FIELD(rear_system.heat_level);
    BASIC_REPLICATION_FIELD(rear_system.coolant_level);
    BASIC_REPLICATION_FIELD(rear_system.coolant_request);
    BASIC_REPLICATION_FIELD(rear_system.can_be_hacked);
    BASIC_REPLICATION_FIELD(rear_system.hacked_level);
    BASIC_REPLICATION_FIELD(rear_system.power_factor);
    BASIC_REPLICATION_FIELD(rear_system.coolant_change_rate_per_second);
    BASIC_REPLICATION_FIELD(rear_system.heat_add_rate_per_second);
    BASIC_REPLICATION_FIELD(rear_system.power_change_rate_per_second);
    BASIC_REPLICATION_FIELD(rear_system.auto_repair_per_second);
    //BASIC_REPLICATION_FIELD(rear_system.damage_per_second_on_overheat); TODO: see below

    //BASIC_REPLICATION_FIELD(calibration_time); TODO: With this we have 33 fields, while basic replication is limited to 32 fields.
    BASIC_REPLICATION_FIELD(calibration_delay);
    BASIC_REPLICATION_FIELD(frequency);

    BASIC_REPLICATION_FIELD(energy_use_per_second);

    BASIC_REPLICATION_VECTOR(entries)
        VECTOR_REPLICATION_FIELD(level);
        VECTOR_REPLICATION_FIELD(max);
        VECTOR_REPLICATION_FIELD(hit_effect);
    VECTOR_REPLICATION_END();
}
