#pragma once

#include "multiplayer/basic.h"
#include "components/faction.h"

BASIC_REPLICATION_CLASS(FactionReplication, Faction);
BASIC_REPLICATION_CLASS_RATE(FactionInfoReplication, FactionInfo, 1.0f);
