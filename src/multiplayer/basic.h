#pragma once

#include "ecs/multiplayer.h"
#include "ecs/query.h"

namespace sp::io {
    template<typename T> static inline DataBuffer& operator << (DataBuffer& packet, const std::vector<T>& v) { packet << uint32_t(v.size()); for(size_t n=0; n<v.size(); n++) packet << v[n]; return packet;} \
    template<typename T> static inline DataBuffer& operator >> (DataBuffer& packet, std::vector<T>& v) { uint32_t size = 0; packet >> size; v.resize(size); for(size_t n=0; n<v.size(); n++) packet >> v[n]; return packet; }
}

enum class BasicReplicationRequest {
    SendAll, Update, Receive
};
#define BASIC_REPLICATION_CLASS(CLASS, COMPONENT) \
    class CLASS : public sp::ecs::ComponentReplicationBase { \
        sp::SparseSet<std::pair<uint32_t, COMPONENT>> info; \
        void onEntityDestroyed(uint32_t index) override; \
        void sendAll(sp::io::DataBuffer& packet) override; \
        void update(sp::io::DataBuffer& packet) override; \
        void receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) override; \
        void remove(sp::ecs::Entity entity) override; \
        template<BasicReplicationRequest> void impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& c, COMPONENT* backup); \
        template<BasicReplicationRequest> void field_impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& c, COMPONENT* backup, sp::io::DataBuffer& tmp, uint32_t& flags); \
    };

#define BASIC_REPLICATION_IMPL(CLASS, COMPONENT) \
    void CLASS::onEntityDestroyed(uint32_t index) { info.remove(index); } \
    void CLASS::sendAll(sp::io::DataBuffer& packet) { \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
        } \
    } \
    void CLASS::update(sp::io::DataBuffer& packet) { \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            if (!info.has(entity.getIndex())) { \
                info.set(entity.getIndex(), {entity.getVersion(), data}); \
                impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
            } else { \
                auto& [version, backup] = info.get(entity.getIndex()); \
                if (version != entity.getVersion()) { \
                    info.set(entity.getIndex(), {entity.getVersion(), data}); \
                    impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
                } else { \
                    impl<BasicReplicationRequest::Update>(entity, packet, data, &backup); \
                } \
            } \
        } \
        for(auto [index, version_data] : info) { auto& [version, data] = version_data; \
            if (!sp::ecs::Entity::forced(index, version).hasComponent<COMPONENT>()) { \
                info.remove(index); \
                packet << CMD_ECS_DEL_COMPONENT << component_index << index; \
            } \
        } \
    } \
    void CLASS::receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) { impl<BasicReplicationRequest::Receive>(entity, packet, entity.getOrAddComponent<COMPONENT>(), nullptr); } \
    void CLASS::remove(sp::ecs::Entity entity) { entity.removeComponent<COMPONENT>(); } \
    template<BasicReplicationRequest BRR> void CLASS::impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& target, COMPONENT* backup) { \
        sp::io::DataBuffer tmp; \
        uint32_t flags = 0; \
        if (BRR == BasicReplicationRequest::Receive) packet >> flags; \
        field_impl<BRR>(entity, packet, target, backup, tmp, flags); \
        if (tmp.getDataSize() > 0) packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex(), flags, tmp); \
    } \
    template<BasicReplicationRequest BRR> void CLASS::field_impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& target, COMPONENT* backup, sp::io::DataBuffer& tmp, uint32_t& flags) { \
        uint32_t flag = 1;

#define BASIC_REPLICATION_FIELD(FIELD) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.FIELD; break; \
    case BasicReplicationRequest::Update: if (target.FIELD != backup->FIELD) { flags |= flag; tmp << target.FIELD; backup->FIELD = target.FIELD; } break; \
    case BasicReplicationRequest::Receive: if (flags & flag) packet >> target.FIELD; break; \
    } \
    flag <<= 1;
#define BASIC_REPLICATION_VECTOR(FIELD) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.FIELD.size(); break; \
    case BasicReplicationRequest::Update: if (target.FIELD.size() != backup->FIELD.size()) { flags |= flag; tmp << target.FIELD.size(); backup->FIELD.resize(target.FIELD.size()); } break; \
    case BasicReplicationRequest::Receive: if (flags & flag) { size_t size; packet >> size; target.FIELD.resize(size); } break; \
    } \
    flag <<= 1; \
    for(size_t idx=0; idx<target.FIELD.size(); idx++) { \
        uint32_t vector_flags = 0; \
        if (BRR == BasicReplicationRequest::Receive) { \
            packet >> vector_flags; \
            if (vector_flags == 0) break; \
            packet >> idx; \
            if (idx >= target.FIELD.size()) break; \
        } \
        auto vector_target = &target.mounts[idx]; \
        auto vector_backup = &backup->mounts[idx]; \
        sp::io::DataBuffer vector_tmp; \
        uint32_t vector_flag = 0;

#define VECTOR_REPLICATION_FIELD(FIELD) \
        switch(BRR) { \
        case BasicReplicationRequest::SendAll: vector_flags |= vector_flag; vector_tmp << vector_target->FIELD; break; \
        case BasicReplicationRequest::Update: if (vector_target->FIELD != vector_backup->FIELD) { vector_flags |= vector_flag; vector_tmp << vector_target->FIELD; vector_backup->FIELD = vector_target->FIELD; } break; \
        case BasicReplicationRequest::Receive: if (vector_flags & vector_flag) packet >> vector_target->FIELD; break; \
        } \
        vector_flag <<= 1;

#define VECTOR_REPLICATION_END() \
        if (vector_tmp.getDataSize() > 0) tmp.write(flags, idx, vector_tmp); \
    } \
    if (tmp.getDataSize() > 0) tmp.write(uint32_t(0)); // end of vector update.



#define EMPTY_REPLICATION_IMPL(CLASS, COMPONENT) \
    void CLASS::onEntityDestroyed(uint32_t index) { info.remove(index); } \
    void CLASS::sendAll(sp::io::DataBuffer& packet) { \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex()); \
        } \
    } \
    void CLASS::update(sp::io::DataBuffer& packet) { \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            if (!info.has(entity.getIndex())) { \
                info.set(entity.getIndex(), {entity.getVersion(), data}); \
                packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex()); \
            } else { \
                auto& [version, backup] = info.get(entity.getIndex()); \
                if (version != entity.getVersion()) { \
                    info.set(entity.getIndex(), {entity.getVersion(), data}); \
                    packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex()); \
                } \
            } \
        } \
        for(auto [index, version_data] : info) { auto& [version, data] = version_data; \
            if (!sp::ecs::Entity::forced(index, version).hasComponent<COMPONENT>()) { \
                info.remove(index); \
                packet << CMD_ECS_DEL_COMPONENT << component_index << index; \
            } \
        } \
    } \
    void CLASS::receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) { entity.getOrAddComponent<COMPONENT>(); } \
    void CLASS::remove(sp::ecs::Entity entity) { entity.removeComponent<COMPONENT>(); }

#define REPLICATE_VECTOR_IF_DIRTY(VECTOR, DIRTY) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.VECTOR; break; \
    case BasicReplicationRequest::Update: if (target.DIRTY) { flags |= flag; tmp << target.VECTOR; target.DIRTY = false; } break; \
    case BasicReplicationRequest::Receive: if (flags & flag) packet >> target.VECTOR; break; \
    } \
    flag <<= 1;
