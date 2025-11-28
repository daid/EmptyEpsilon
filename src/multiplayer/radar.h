#pragma once

#include "multiplayer/basic.h"
#include "components/radar.h"

BASIC_REPLICATION_CLASS(RadarTraceReplication, RadarTrace);
BASIC_REPLICATION_CLASS(RawRadarSignatureInfoReplication, RawRadarSignatureInfo);
BASIC_REPLICATION_CLASS(LongRangeRadarReplication, LongRangeRadar);
BASIC_REPLICATION_CLASS(RadarLinkReplication, RadarLink);
BASIC_REPLICATION_CLASS(ShareShortRangeRadarReplication, ShareShortRangeRadar);
BASIC_REPLICATION_CLASS(AllowRadarLinkReplication, AllowRadarLink);
