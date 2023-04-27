#pragma once

#include "ecs/entity.h"
#include "shipsystem.h"
#include "missileWeaponData.h"
#include "shipTemplate.h"
#include <glm/vec3.hpp>


class MissileTubes : public ShipSystem {
public:
    class MountPoint {
    public:
        enum class State
        {
            Empty,
            Loading,
            Loaded,
            Unloading,
            Firing
        };

        //Configuration
        glm::vec3 position{};//Visual position on the 3D model where this beam is fired from.
        float load_time = 8.0f;
        uint32_t type_allowed_mask = (1 << MW_Count) - 1;
        float direction = 0.0f;
        EMissileSizes size = MS_Medium;

        //Runtime state
        EMissileWeapons type_loaded = MW_None;
        State state = State::Empty;
        float delay = 0.0f;
        int fire_count = 0;

        bool canLoad(EMissileWeapons type) {
            return (type_allowed_mask & (1 << type));
        }
        bool canOnlyLoad(EMissileWeapons type) {
            return (type_allowed_mask == (1U << type));
        }
    };

    int storage[MW_Count] = {0};
    int storage_max[MW_Count] = {0};

    std::vector<MountPoint> mounts;
};
