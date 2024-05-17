#include "multiplayer/beamweapon.h"
#include "multiplayer.h"

BASIC_REPLICATION_IMPL(BeamWeaponSysReplication, BeamWeaponSys)
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
    BASIC_REPLICATION_FIELD(frequency);
    BASIC_REPLICATION_FIELD(system_target);

    BASIC_REPLICATION_VECTOR(mounts)
        VECTOR_REPLICATION_FIELD(position);
        VECTOR_REPLICATION_FIELD(arc);
        VECTOR_REPLICATION_FIELD(direction);
        VECTOR_REPLICATION_FIELD(range);
        VECTOR_REPLICATION_FIELD(turret_arc);
        VECTOR_REPLICATION_FIELD(turret_direction);
        VECTOR_REPLICATION_FIELD(turret_rotation_rate);
        VECTOR_REPLICATION_FIELD(cycle_time);
        VECTOR_REPLICATION_FIELD(damage);
        VECTOR_REPLICATION_FIELD(energy_per_beam_fire);
        VECTOR_REPLICATION_FIELD(heat_per_beam_fire);
        VECTOR_REPLICATION_FIELD(arc_color);
        VECTOR_REPLICATION_FIELD(arc_color_fire);
        VECTOR_REPLICATION_FIELD(damage_type);
        VECTOR_REPLICATION_FIELD(cooldown);
        VECTOR_REPLICATION_FIELD(texture);
    VECTOR_REPLICATION_END();
}


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
