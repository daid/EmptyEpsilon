#include "multiplayer/missiletubes.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(MissileTubesReplication, MissileTubes)
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

    BASIC_REPLICATION_FIELD(storage[MW_Homing]);
    BASIC_REPLICATION_FIELD(storage[MW_Nuke]);
    BASIC_REPLICATION_FIELD(storage[MW_Mine]);
    BASIC_REPLICATION_FIELD(storage[MW_EMP]);
    BASIC_REPLICATION_FIELD(storage[MW_HVLI]);
    BASIC_REPLICATION_FIELD(storage_max[MW_Homing]);
    BASIC_REPLICATION_FIELD(storage_max[MW_Nuke]);
    BASIC_REPLICATION_FIELD(storage_max[MW_Mine]);
    BASIC_REPLICATION_FIELD(storage_max[MW_EMP]);
    BASIC_REPLICATION_FIELD(storage_max[MW_HVLI]);

    BASIC_REPLICATION_VECTOR(mounts)
        VECTOR_REPLICATION_FIELD(position);
        VECTOR_REPLICATION_FIELD(load_time);
        VECTOR_REPLICATION_FIELD(type_allowed_mask);
        VECTOR_REPLICATION_FIELD(direction);
        VECTOR_REPLICATION_FIELD(size);

        VECTOR_REPLICATION_FIELD(type_loaded);
        VECTOR_REPLICATION_FIELD(state);
        VECTOR_REPLICATION_FIELD(delay);
        VECTOR_REPLICATION_FIELD(fire_count);
    VECTOR_REPLICATION_END();
}
