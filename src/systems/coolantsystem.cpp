#include "coolantsystem.h"
#include "ecs/query.h"
#include "components/coolant.h"
#include "components/shipsystem.h"

void CoolantSystem::update(float delta)
{
    for (auto[entity, coolant] : sp::ecs::Query<Coolant>())
    {
        // Automate coolant distribution if auto_levels is set. Distribute to
        // systems in proportion to their share of the total generated heat.
        if (coolant.auto_levels)
        {
            float total_heat = 0.0f;

            for (int n = 0; n < ShipSystem::COUNT; n++)
            {
                auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                if (!sys) continue;
                total_heat += sys->heat_level;
            }

            if (total_heat > 0.0f)
            {
                bool excess_redistributed;

                // Calculate ideal proportional distribution.
                for (int n = 0; n < ShipSystem::COUNT; n++)
                {
                    auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                    if (!sys) continue;
                    sys->coolant_request = coolant.max * sys->heat_level / total_heat;
                }

                // Check for excess coolant from capped systems and redistribute
                // it if necessary.
                do
                {
                    excess_redistributed = false;
                    float excess_coolant = 0.0f;
                    float available_heat = 0.0f;

                    // Find systems requesting more than max_coolant_per_system
                    // and calculate excess.
                    for (int n = 0; n < ShipSystem::COUNT; n++)
                    {
                        auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                        if (!sys) continue;

                        if (sys->coolant_request > coolant.max_coolant_per_system)
                        {
                            excess_coolant += sys->coolant_request - coolant.max_coolant_per_system;
                            sys->coolant_request = coolant.max_coolant_per_system;
                        }
                        else if (sys->coolant_request < coolant.max_coolant_per_system && sys->heat_level > 0.0f)
                            available_heat += sys->heat_level;
                    }

                    // Redistribute excess coolant proportionally to uncapped
                    // systems that have heat, if any.
                    if (excess_coolant > 0.0f && available_heat > 0.0f)
                    {
                        for (int n = 0; n < ShipSystem::COUNT; n++)
                        {
                            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
                            if (!sys) continue;

                            if (sys->coolant_request < coolant.max_coolant_per_system && sys->heat_level > 0.0f)
                            {
                                sys->coolant_request += excess_coolant * sys->heat_level / available_heat;
                                excess_redistributed = true;
                            }
                        }
                    }
                } while (excess_redistributed);
            }
        }

        // Otherwise, distribute coolant manually. System limits are instead
        // enforced by UI controls.

        // Check how much coolant we have requested in total, and if that's beyond the
        // amount of coolant we have, see how much we need to adjust our request.
        float total_coolant_request = 0.0f;
        float coolant_request_factor = 1.0f;

        for (int n = 0; n < ShipSystem::COUNT; n++)
        {
            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (sys) total_coolant_request += sys->coolant_request;
        }

        if (total_coolant_request > coolant.max)
            coolant_request_factor = coolant.max / total_coolant_request;

        for (int n = 0; n < ShipSystem::COUNT; n++)
        {
            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (!sys) continue;

            float coolant_request = sys->coolant_request * coolant_request_factor;

            if (coolant_request > sys->coolant_level)
            {
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