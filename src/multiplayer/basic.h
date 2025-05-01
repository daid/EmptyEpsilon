#pragma once

#include "ecs/multiplayer.h"
#include "ecs/query.h"
#include "engine.h"


namespace sp::io {
    template<typename T> static inline DataBuffer& operator << (DataBuffer& packet, const std::vector<T>& v) { packet << uint32_t(v.size()); for(size_t n=0; n<v.size(); n++) packet << v[n]; return packet;} \
    template<typename T> static inline DataBuffer& operator >> (DataBuffer& packet, std::vector<T>& v) { uint32_t size = 0; packet >> size; v.resize(size); for(size_t n=0; n<v.size(); n++) packet >> v[n]; return packet; }
}

enum class BasicReplicationRequest {
    SendAll, Update, Receive
};
#define BASIC_REPLICATION_CLASS_RATE(CLASS, COMPONENT, RATE) \
    class CLASS : public sp::ecs::ComponentReplicationBase { \
        static constexpr float update_delay = 1.0f / (RATE); \
        struct Info { uint32_t version; float last_update = 0.0f; COMPONENT data; }; \
        sp::SparseSet<Info> info; \
        void onEntityDestroyed(uint32_t index) override; \
        void sendAll(sp::io::DataBuffer& packet) override; \
        void update(sp::io::DataBuffer& packet) override; \
        void receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) override; \
        void remove(sp::ecs::Entity entity) override; \
        template<BasicReplicationRequest> bool impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& c, COMPONENT* backup); \
        template<BasicReplicationRequest> void field_impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& c, COMPONENT* backup, sp::io::DataBuffer& tmp, uint32_t& flags); \
    };
#define BASIC_REPLICATION_CLASS(CLASS, COMPONENT) \
    BASIC_REPLICATION_CLASS_RATE(CLASS, COMPONENT, 60.0f);

#define BASIC_REPLICATION_IMPL(CLASS, COMPONENT) \
    void CLASS::onEntityDestroyed(uint32_t index) { info.remove(index); } \
    void CLASS::sendAll(sp::io::DataBuffer& packet) { \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
        } \
    } \
    void CLASS::update(sp::io::DataBuffer& packet) { \
        auto now = engine->getElapsedTime(); \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            if (!info.has(entity.getIndex())) { \
                info.set(entity.getIndex(), {entity.getVersion(), now, data}); \
                impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
            } else { \
                auto& entity_info = info.get(entity.getIndex()); \
                if (entity_info.version != entity.getVersion()) { \
                    info.set(entity.getIndex(), {entity.getVersion(), now, data}); \
                    impl<BasicReplicationRequest::SendAll>(entity, packet, data, nullptr); \
                } else if (entity_info.last_update + update_delay <= now) { \
                    if (impl<BasicReplicationRequest::Update>(entity, packet, data, &entity_info.data)) entity_info.last_update = now; \
                } \
            } \
        } \
        for(auto [index, entity_info] : info) { \
            if (!sp::ecs::Entity::forced(index, entity_info.version).hasComponent<COMPONENT>()) { \
                info.remove(index); \
                packet << CMD_ECS_DEL_COMPONENT << component_index << index; \
            } \
        } \
    } \
    void CLASS::receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) { impl<BasicReplicationRequest::Receive>(entity, packet, entity.getOrAddComponent<COMPONENT>(), nullptr); } \
    void CLASS::remove(sp::ecs::Entity entity) { entity.removeComponent<COMPONENT>(); } \
    template<BasicReplicationRequest BRR> bool CLASS::impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& target, COMPONENT* backup) { \
        sp::io::DataBuffer tmp; \
        uint32_t flags = 0; \
        if (BRR == BasicReplicationRequest::Receive) packet >> flags; \
        field_impl<BRR>(entity, packet, target, backup, tmp, flags); \
        if (tmp.getDataSize() > 0) packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex(), flags, tmp); \
        return tmp.getDataSize() > 0; \
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
#define BASIC_REPLICATION_PAIR(FIELD_A, FIELD_B) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.FIELD_A; tmp << target.FIELD_B; break; \
    case BasicReplicationRequest::Update: if (target.FIELD_A != backup->FIELD_A || target.FIELD_B != backup->FIELD_B) { flags |= flag; tmp << target.FIELD_A; backup->FIELD_A = target.FIELD_A; tmp << target.FIELD_B; backup->FIELD_B = target.FIELD_B; } break; \
    case BasicReplicationRequest::Receive: if (flags & flag) { packet >> target.FIELD_A; packet >> target.FIELD_B; }; break; \
    } \
    flag <<= 1;
#define BASIC_REPLICATION_VECTOR(FIELD) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.FIELD.size(); break; \
    case BasicReplicationRequest::Update: if (target.FIELD.size() != backup->FIELD.size()) { flags |= flag; tmp << target.FIELD.size(); backup->FIELD.resize(target.FIELD.size()); } break; \
    case BasicReplicationRequest::Receive: if (flags & flag) { size_t size; packet >> size; target.FIELD.resize(size); } break; \
    } \
    flag <<= 1; \
    for(size_t idx=0; (BRR==BasicReplicationRequest::Receive) || idx<target.FIELD.size(); idx++) { \
        uint32_t vector_flags = 0; \
        if (BRR == BasicReplicationRequest::Receive) { \
            packet >> vector_flags; \
            if (vector_flags == 0) break; \
            packet >> idx; \
            if (idx >= target.FIELD.size()) { LOG(Warning, "Vector replication index out of range..."); break; } \
        } \
        auto vector_target = &target.FIELD[idx]; \
        auto vector_backup = backup ? &backup->FIELD[idx] : nullptr; \
        sp::io::DataBuffer vector_tmp; \
        uint32_t vector_flag = 1;

#define VECTOR_REPLICATION_FIELD(FIELD) \
        switch(BRR) { \
        case BasicReplicationRequest::SendAll: vector_flags |= vector_flag; vector_tmp << vector_target->FIELD; break; \
        case BasicReplicationRequest::Update: if (vector_target->FIELD != vector_backup->FIELD) { vector_flags |= vector_flag; vector_tmp << vector_target->FIELD; vector_backup->FIELD = vector_target->FIELD; } break; \
        case BasicReplicationRequest::Receive: if (vector_flags & vector_flag) packet >> vector_target->FIELD; break; \
        } \
        vector_flag <<= 1;

#define VECTOR_REPLICATION_END() \
        if (vector_tmp.getDataSize() > 0) tmp.write(vector_flags, idx, vector_tmp); \
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
        auto now = engine->getElapsedTime(); \
        for(auto [entity, data] : sp::ecs::Query<COMPONENT>()) { \
            if (!info.has(entity.getIndex())) { \
                info.set(entity.getIndex(), {entity.getVersion(), now, data}); \
                packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex()); \
            } else { \
                auto& entity_info = info.get(entity.getIndex()); \
                if (entity_info.version != entity.getVersion()) { \
                    info.set(entity.getIndex(), {entity.getVersion(), now, data}); \
                    packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex()); \
                } \
            } \
        } \
        for(auto [index, entity_info] : info) { \
            if (!sp::ecs::Entity::forced(index, entity_info.version).hasComponent<COMPONENT>()) { \
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
