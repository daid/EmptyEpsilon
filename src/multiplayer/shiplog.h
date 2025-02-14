#pragma once

#include "multiplayer.h"
#include "ecs/multiplayer.h"
#include "components/shiplog.h"

class ShipLogReplication : public sp::ecs::ComponentReplicationBase {
    struct Info { uint32_t version; };
    sp::SparseSet<Info> info;

    void onEntityDestroyed(uint32_t index) override;
    void sendAll(sp::io::DataBuffer& packet) override;
    void update(sp::io::DataBuffer& packet) override;
    void receive(sp::ecs::Entity entity, sp::io::DataBuffer& packet) override;
    void remove(sp::ecs::Entity entity) override;

    void addFullUpdate(sp::io::DataBuffer& packet, sp::ecs::Entity entity, const ShipLog& log);
};