#pragma once

#include "multiplayer/basic.h"
#include "components/beamweapon.h"

BASIC_REPLICATION_CLASS_RATE(BeamWeaponSysReplication, BeamWeaponSys, 20.0f);
BASIC_REPLICATION_CLASS(BeamEffectReplication, BeamEffect);
