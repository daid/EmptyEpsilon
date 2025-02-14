#pragma once

#include "multiplayer/basic.h"
#include "components/missile.h"

BASIC_REPLICATION_CLASS(MissileFlightReplication, MissileFlight);
BASIC_REPLICATION_CLASS(MissileHomingReplication, MissileHoming);
BASIC_REPLICATION_CLASS(ConstantParticleEmitterReplication, ConstantParticleEmitter);
