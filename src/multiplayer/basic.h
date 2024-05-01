#pragma once

#include "ecs/multiplayer.h"
#include "ecs/query.h"


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
        uint32_t flags; \
        if (BRR == BasicReplicationRequest::Receive) packet >> flags; \
        field_impl<BRR>(entity, packet, target, backup, tmp, flags); \
        if (tmp.getDataSize() > 0) packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex(), flags, tmp); \
    } \
    template<BasicReplicationRequest BRR> void CLASS::field_impl(sp::ecs::Entity entity, sp::io::DataBuffer& packet, COMPONENT& target, COMPONENT* backup, sp::io::DataBuffer& tmp, uint32_t& flags) { \
        uint32_t flag = 1;

#define BASIC_REPLICATION_FIELD(FIELD) \
    switch(BRR) { \
    case BasicReplicationRequest::SendAll: flags |= flag; tmp << target.FIELD; break; \
    case BasicReplicationRequest::Update: flags |= flag; tmp << target.FIELD; break; \
    case BasicReplicationRequest::Receive: if (flags & 1) packet >> target.FIELD; break; \
    } \
    flag <<= 1;



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
