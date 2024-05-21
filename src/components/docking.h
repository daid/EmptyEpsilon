#pragma once

#include <unordered_set>
#include "io/dataBuffer.h"
#include "multiplayer.h"

// Component that indicates things can dock to this.
enum class DockingStyle {
    None, External, Internal,
};

class DockingBay
{
public:
    static constexpr uint32_t ShareEnergy = 1 << 0;
    static constexpr uint32_t Repair = 1 << 1;
    static constexpr uint32_t ChargeShield = 1 << 2; // Increased shield recharge rate
    static constexpr uint32_t RestockProbes = 1 << 3;
    static constexpr uint32_t RestockMissiles = 1 << 4;  // Only for AI controlled ships. Players use the comms system.

    std::unordered_set<string> external_dock_classes;
    bool external_dock_classes_dirty = true;
    std::unordered_set<string> internal_dock_classes;
    bool internal_dock_classes_dirty = true;

    uint32_t flags = 0;
};

// Component to indicate that we can do to things.
class DockingPort
{
public:
    string dock_class;
    string dock_subclass;

    enum class State {
        NotDocking = 0,
        Docking,
        Docked
    } state = State::NotDocking;
    
    sp::ecs::Entity target;
    glm::vec2 docked_offset;

    bool auto_reload_missiles = false; //TODO: Set to true on CpuShips
    float auto_reload_missile_delay = 0.0f;
    static constexpr float auto_reload_missile_time = 10.0f;

    DockingStyle canDockOn(DockingBay& bay) {
        if (bay.external_dock_classes.empty() && bay.internal_dock_classes.empty()) return DockingStyle::External;
        if (bay.external_dock_classes.find(dock_class) != bay.external_dock_classes.end()) return DockingStyle::External;
        if (bay.external_dock_classes.find(dock_subclass) != bay.external_dock_classes.end()) return DockingStyle::External;
        if (bay.internal_dock_classes.find(dock_class) != bay.internal_dock_classes.end()) return DockingStyle::Internal;
        if (bay.internal_dock_classes.find(dock_subclass) != bay.internal_dock_classes.end()) return DockingStyle::Internal;
        return DockingStyle::None;
    }
};