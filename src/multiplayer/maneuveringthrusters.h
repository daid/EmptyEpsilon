#pragma once

#include "multiplayer/basic.h"
#include "components/maneuveringthrusters.h"

BASIC_REPLICATION_CLASS_RATE(ManeuveringThrustersReplication, ManeuveringThrusters, 20.0f);
BASIC_REPLICATION_CLASS_RATE(CombatManeuveringThrustersReplication, CombatManeuveringThrusters, 20.0f);
