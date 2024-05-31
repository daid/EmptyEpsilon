#include "multiplayer/missile.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(MissileFlightReplication, MissileFlight)
    BASIC_REPLICATION_FIELD(speed);
}

BASIC_REPLICATION_IMPL(MissileHomingReplication, MissileHoming)
    BASIC_REPLICATION_FIELD(turn_rate);
    BASIC_REPLICATION_FIELD(range);
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(target_angle);
}

BASIC_REPLICATION_IMPL(ConstantParticleEmitterReplication, ConstantParticleEmitter)
    BASIC_REPLICATION_FIELD(interval);
    BASIC_REPLICATION_FIELD(travel_random_range);
    BASIC_REPLICATION_FIELD(start_color);
    BASIC_REPLICATION_FIELD(end_color);
    BASIC_REPLICATION_FIELD(start_size);
    BASIC_REPLICATION_FIELD(end_size);
    BASIC_REPLICATION_FIELD(life_time);
}
