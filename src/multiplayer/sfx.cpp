#include "multiplayer/sfx.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(SfxReplication, Sfx)
    BASIC_REPLICATION_FIELD(sound);
    BASIC_REPLICATION_FIELD(volume);
    BASIC_REPLICATION_FIELD(pitch);
}
