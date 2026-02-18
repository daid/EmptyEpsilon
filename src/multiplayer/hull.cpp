#include "multiplayer/hull.h"
#include "multiplayer.h"


// Hull is now a marker component with no fields to replicate
EMPTY_REPLICATION_IMPL(HullReplication, Hull)