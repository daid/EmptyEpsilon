#include "multiplayer/beamweapon.h"


BASIC_REPLICATION_IMPL(BeamEffectReplication, BeamEffect)
    BASIC_REPLICATION_FIELD(lifetime);
    BASIC_REPLICATION_FIELD(source);
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(source_offset);
    BASIC_REPLICATION_FIELD(target_offset);
    BASIC_REPLICATION_FIELD(target_location);
    BASIC_REPLICATION_FIELD(hit_normal);

    BASIC_REPLICATION_FIELD(fire_ring);
    BASIC_REPLICATION_FIELD(beam_texture);
}
