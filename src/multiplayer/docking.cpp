#include "multiplayer/docking.h"
#include "multiplayer.h"

namespace sp::io {
    template<typename T> static inline DataBuffer& operator << (DataBuffer& packet, const std::unordered_set<T>& s) {
        packet << uint32_t(s.size());
        for(const auto v : s) packet << v;
        return packet;
    }
    template<typename T> static inline DataBuffer& operator >> (DataBuffer& packet, std::unordered_set<T>& s) {
        uint32_t size = 0;
        packet >> size;
        s.clear();
        for(size_t n=0; n<size; n++) {
            T v;
            packet >> v;
            s.insert(v);
        }
        return packet;
    }
}


BASIC_REPLICATION_IMPL(DockingBayReplication, DockingBay)
    REPLICATE_VECTOR_IF_DIRTY(external_dock_classes, external_dock_classes_dirty);
    REPLICATE_VECTOR_IF_DIRTY(internal_dock_classes, internal_dock_classes_dirty);
}

BASIC_REPLICATION_IMPL(DockingPortReplication, DockingPort)
    BASIC_REPLICATION_FIELD(dock_class);
    BASIC_REPLICATION_FIELD(dock_subclass);
    BASIC_REPLICATION_FIELD(state);
    BASIC_REPLICATION_FIELD(target);
    BASIC_REPLICATION_FIELD(docked_offset);
}