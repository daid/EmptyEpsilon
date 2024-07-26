#include "multiplayer/rendering.h"
#include "multiplayer.h"

namespace sp::io {
    static inline DataBuffer& operator << (DataBuffer& packet, const EngineEmitter::Emitter& e) { return packet << e.position << e.color << e.scale; } \
    static inline DataBuffer& operator >> (DataBuffer& packet, EngineEmitter::Emitter& e) { packet >> e.position >> e.color >> e.scale; return packet; }
    static inline DataBuffer& operator << (DataBuffer& packet, const NebulaRenderer::Cloud& c) { return packet << c.offset << c.texture.name << c.size; } \
    static inline DataBuffer& operator >> (DataBuffer& packet, NebulaRenderer::Cloud& c) { packet >> c.offset >> c.texture.name >> c.size; return packet; }
}

BASIC_REPLICATION_IMPL(MeshRenderComponentReplication, MeshRenderComponent)
    BASIC_REPLICATION_FIELD(mesh.name);
    BASIC_REPLICATION_FIELD(texture.name);
    BASIC_REPLICATION_FIELD(specular_texture.name);
    BASIC_REPLICATION_FIELD(illumination_texture.name);
    BASIC_REPLICATION_FIELD(mesh_offset);
    BASIC_REPLICATION_FIELD(scale);
}

BASIC_REPLICATION_IMPL(EngineEmitterReplication, EngineEmitter)
    REPLICATE_VECTOR_IF_DIRTY(emitters, emitters_dirty);
}
BASIC_REPLICATION_IMPL(NebulaRendererReplication, NebulaRenderer)
    BASIC_REPLICATION_FIELD(render_range);
    REPLICATE_VECTOR_IF_DIRTY(clouds, clouds_dirty);
}
BASIC_REPLICATION_IMPL(ExplosionEffectReplication, ExplosionEffect)
    BASIC_REPLICATION_FIELD(size);
    BASIC_REPLICATION_FIELD(radar);
    BASIC_REPLICATION_FIELD(electrical);
}
BASIC_REPLICATION_IMPL(PlanetRenderReplication, PlanetRender)
    BASIC_REPLICATION_FIELD(size);
    BASIC_REPLICATION_FIELD(cloud_size);
    BASIC_REPLICATION_FIELD(atmosphere_size);
    BASIC_REPLICATION_FIELD(texture);
    BASIC_REPLICATION_FIELD(cloud_texture);
    BASIC_REPLICATION_FIELD(atmosphere_texture);
    BASIC_REPLICATION_FIELD(atmosphere_color);
    BASIC_REPLICATION_FIELD(distance_from_movement_plane);
}