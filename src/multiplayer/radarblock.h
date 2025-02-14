#pragma once

#include "multiplayer/basic.h"
#include "components/radarblock.h"

BASIC_REPLICATION_CLASS(RadarBlockReplication, RadarBlock);
BASIC_REPLICATION_CLASS(NeverRadarBlockedReplication, NeverRadarBlocked);
