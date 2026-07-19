#include "multiplayer/shiplog.h"
#include "ecs/query.h"
#include "components/shiplog.h"

static constexpr unsigned int FULL_UPDATE = 0;
static constexpr unsigned int ADDITION = 1;


void ShipLogReplication::onEntityDestroyed(uint32_t index)
{
    info.remove(index);
}

void ShipLogReplication::sendAll(sp::io::DataBuffer& packet)
{
    for(auto [entity, log] : sp::ecs::Query<ShipLog>()) {
        addFullUpdate(packet, entity, log);
    }
}

void ShipLogReplication::update(sp::io::DataBuffer& packet)
{
    for(auto [entity, log] : sp::ecs::Query<ShipLog>()) {
        if (log.cleared) {
            addFullUpdate(packet, entity, log);
            log.cleared = false;
        } else if (log.new_entry_count > 0) {
            auto new_entries = std::min(log.new_entry_count, log.size());
            packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex(), ADDITION, new_entries);
            for(size_t n=log.size() - new_entries; n<log.size(); n++) {
                const auto& e = log.get(n);
                packet << e.prefix << e.text << e.color;
            }
            log.new_entry_count = 0;
        }
        info.set(entity.getIndex(), {entity.getVersion()});
    }
    for(auto [index, entity_info] : info) {
        if (!sp::ecs::Entity::forced(index, entity_info.version).hasComponent<ShipLog>()) {
            info.remove(index);
            packet << CMD_ECS_DEL_COMPONENT << component_index << index;
        }
    }
}

void ShipLogReplication::receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet)
{
    auto& log = entity.getOrAddComponent<ShipLog>();
    unsigned int update_type = 0;
    size_t amount = 0;
    packet >> update_type >> amount;
    if (update_type == FULL_UPDATE)
        log.clear();
    for(size_t n=0; n<amount; n++) {
        string prefix, message;
        glm::u8vec4 color;
        packet >> prefix >> message >> color;
        log.add(prefix, message, color);
    }
}

void ShipLogReplication::remove(sp::ecs::Entity entity)
{
    entity.removeComponent<ShipLog>();
}

void ShipLogReplication::addFullUpdate(sp::io::DataBuffer& packet, sp::ecs::Entity entity, const ShipLog& log)
{
    packet.write(CMD_ECS_SET_COMPONENT, component_index, entity.getIndex(), FULL_UPDATE, log.size());
    for(size_t n=0; n<log.size(); n++) {
        const auto& e = log.get(n);
        packet << e.prefix << e.text << e.color;
    }
}