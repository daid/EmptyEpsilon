#include "multiplayer/customshipfunction.h"
#include "multiplayer.h"

static inline sp::io::DataBuffer& operator << (sp::io::DataBuffer& packet, const CustomShipFunctions::Function& csf) {
    return packet << csf.type << csf.crew_positions.mask << csf.name << csf.caption;
}
static inline sp::io::DataBuffer& operator >> (sp::io::DataBuffer& packet, CustomShipFunctions::Function& csf) {
    packet >> csf.type >> csf.crew_positions.mask >> csf.name >> csf.caption;
    return packet;
}


BASIC_REPLICATION_IMPL(CustomShipFunctionsReplication, CustomShipFunctions)
    REPLICATE_VECTOR_IF_DIRTY(functions, functions_dirty);
}