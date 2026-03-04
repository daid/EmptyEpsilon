#include "multiplayer/postprocessor.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(GlitchPostProcessorReplication, GlitchPostProcessor)
    BASIC_REPLICATION_FIELD(max_radius);
    BASIC_REPLICATION_FIELD(min_radius);
    BASIC_REPLICATION_FIELD(effect_strength);
}

BASIC_REPLICATION_IMPL(WarpPostProcessorReplication, WarpPostProcessor)
    BASIC_REPLICATION_FIELD(max_radius);
    BASIC_REPLICATION_FIELD(min_radius);
    BASIC_REPLICATION_FIELD(effect_strength);
}
