#include "multiplayer/radar.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(RadarTraceReplication, RadarTrace)
    BASIC_REPLICATION_FIELD(icon);
    BASIC_REPLICATION_FIELD(min_size);
    BASIC_REPLICATION_FIELD(max_size);
    BASIC_REPLICATION_FIELD(radius);
    BASIC_REPLICATION_FIELD(color);
    BASIC_REPLICATION_FIELD(flags);
}

BASIC_REPLICATION_IMPL(RawRadarSignatureInfoReplication, RawRadarSignatureInfo)
    BASIC_REPLICATION_FIELD(gravity);
    BASIC_REPLICATION_FIELD(electrical);
    BASIC_REPLICATION_FIELD(biological);
}
BASIC_REPLICATION_IMPL(LongRangeRadarReplication, LongRangeRadar)
    BASIC_REPLICATION_FIELD(short_range);
    BASIC_REPLICATION_FIELD(long_range);
}
BASIC_REPLICATION_IMPL(RadarLinkReplication, RadarLink)
    BASIC_REPLICATION_FIELD(linked_entity);
}
EMPTY_REPLICATION_IMPL(ShareShortRangeRadarReplication, ShareShortRangeRadar);
BASIC_REPLICATION_IMPL(AllowRadarLinkReplication, AllowRadarLink)
    BASIC_REPLICATION_FIELD(owner);
}
