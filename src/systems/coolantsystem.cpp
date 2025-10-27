#include "coolantsystem.h"
#include "ecs/query.h"
#include "components/coolant.h"
#include "components/shipsystem.h"


void CoolantSystem::update(float delta)
{
    for(auto[entity, coolant] : sp::ecs::Query<Coolant>()) {
        // Automate cooling if auto_coolant_enabled is true. Distributes coolant to
        // subsystems proportionally to their share of the total generated heat.
        if (coolant.auto_levels) {
            float total_heat = 0.0f;
            for(int n = 0; n < ShipSystem::COUNT; n++) {
                auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                if (!sys) continue;
                total_heat += sys->heat_level;
            }
            if (total_heat > 0.0f) {
                for(int n = 0; n < ShipSystem::COUNT; n++) {
                    auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                    if (!sys) continue;
                    sys->coolant_request = std::min(coolant.max * sys->heat_level / total_heat, coolant.max_coolant_per_system);
                }
            }
        }

        // Check how much coolant we have requested in total, and if that's beyond the
        //  amount of coolant we have, see how much we need to adjust our request.
        float total_coolant_request = 0.0f;
        for(int n = 0; n < ShipSystem::COUNT; n++) {
            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (sys) total_coolant_request += sys->coolant_request;
        }
        float coolant_request_factor = 1.0f;
        if (total_coolant_request > coolant.max)
            coolant_request_factor = coolant.max / total_coolant_request;

        for(int n = 0; n < ShipSystem::COUNT; n++) {
            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (!sys) continue;

            float coolant_request = sys->coolant_request * coolant_request_factor;
            if (coolant_request > sys->coolant_level) {
                sys->coolant_level += delta * sys->coolant_change_rate_per_second;
                if (sys->coolant_level > coolant_request)
                    sys->coolant_level = coolant_request;
            }
            else if (coolant_request < sys->coolant_level)
            {
                sys->coolant_level -= delta * sys->coolant_change_rate_per_second;
                if (sys->coolant_level < coolant_request)
                    sys->coolant_level = coolant_request;
            }
        }
    }
}