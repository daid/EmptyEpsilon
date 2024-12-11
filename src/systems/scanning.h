#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"


class ScanningSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static void scanningFinished(sp::ecs::Entity source);
};
