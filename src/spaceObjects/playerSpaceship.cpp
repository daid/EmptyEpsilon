#include "playerSpaceship.h"
#include "gui/colorConfig.h"
#include "gameGlobalInfo.h"
#include "main.h"
#include "preferenceManager.h"
#include "soundManager.h"
#include "random.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

#include "components/collision.h"
#include "components/impulse.h"
#include "components/hull.h"
#include "components/customshipfunction.h"
#include "components/shiplog.h"
#include "components/probe.h"
#include "components/reactor.h"
#include "components/coolant.h"
#include "components/beamweapon.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/shields.h"
#include "components/target.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/selfdestruct.h"
#include "components/hacking.h"
#include "components/internalrooms.h"
#include "systems/jumpsystem.h"
#include "systems/docking.h"
#include "systems/missilesystem.h"
#include "systems/selfdestruct.h"
#include "systems/comms.h"

#include "scriptInterface.h"

#include <SDL_assert.h>



REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");
PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship", 5000)
{
    // For now, set player ships to always be fully scanned to all other ships
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        setScannedStateForFaction(entity, ScanState::State::FullScan);

    if (game_server)
    {
        // Initialize the ship's log.
        addToShipLog(tr("shiplog", "Start of log"), colorConfig.log_generic);
    }

    // Initialize player ship callsigns with a "PL" designation.
    setCallSign("PL" + string(getMultiplayerId()));

    if (entity) {
        setFaction("Human Navy");
    }
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
PlayerSpaceship::~PlayerSpaceship()
{
}

void PlayerSpaceship::applyTemplateValues()
{
    // Apply default spaceship object values first.
    SpaceShip::applyTemplateValues();

    // Set the ship's number of repair crews in Engineering from the ship's
    // template.
    //setRepairCrewCount(ship_template->repair_crew_count);

    if (entity) {
        entity.getOrAddComponent<Coolant>();
        /*
        if (!ship_template->can_combat_maneuver)
            entity.removeComponent<CombatManeuveringThrusters>();
        if (ship_template->can_self_destruct)
            entity.getOrAddComponent<SelfDestruct>();
        if (ship_template->can_scan)
            entity.getOrAddComponent<ScienceScanner>();
        if (ship_template->can_launch_probe)
            entity.getOrAddComponent<ScanProbeLauncher>();
        if (ship_template->can_hack)
            entity.getOrAddComponent<HackingDevice>();
        */
    }

    if (!on_new_player_ship_called)
    {
        on_new_player_ship_called = true;
        gameGlobalInfo->on_new_player_ship.call<void>(entity);
    }
}

void PlayerSpaceship::setMaxCoolant(float coolant)
{
    //TODO
}

void PlayerSpaceship::setSystemCoolantRequest(ShipSystem::Type system, float request)
{
    auto coolant = entity.getComponent<Coolant>();
    if (!coolant) return;
    request = std::clamp(request, 0.0f, std::min((float) coolant->max_coolant_per_system, coolant->max));
    auto sys = ShipSystem::get(entity, system);
    if (sys)
        sys->coolant_request = request;
}

int PlayerSpaceship::getRepairCrewCount()
{
    // Count and return the number of repair crews on this ship.
    int count = 0;
    for(auto [entity, ic, irc] : sp::ecs::Query<InternalCrew, InternalRepairCrew>())
        if (ic.ship == entity)
            count++;
    return count;
}

void PlayerSpaceship::setRepairCrewCount(int amount)
{
    // This is a server-only function, and we only care about repair crews when
    // we care about subsystem damage.
    if (!game_server || !gameGlobalInfo->use_system_damage)
        return;

    // Prevent negative values.
    amount = std::max(0, amount);

    // Get the number of repair crews for this ship.
    int count = 0;
    for(auto [entity, ic, irc] : sp::ecs::Query<InternalCrew, InternalRepairCrew>()) {
        if (ic.ship != entity) continue;
        count++;
        if (count >= amount)
            entity.destroy();
    }

    auto ir = entity.getComponent<InternalRooms>();
    if (!ir || ir->rooms.empty())
    {
        LOG(WARNING) << "Not adding repair crew to ship \"" << getCallSign() << "\", because it has no rooms. Fix this by adding rooms to the ship template \"" << template_name << "\".";
        return;
    }

    // Add crews until we reach the provided amount.
    for(int create_amount = amount - count; create_amount > 0; create_amount--)
    {
        auto new_crew = sp::ecs::Entity::create();
        new_crew.addComponent<InternalCrew>().ship = entity;
        new_crew.addComponent<InternalRepairCrew>();
    }
}

void PlayerSpaceship::addToShipLog(string message, glm::u8vec4 color)
{
    auto& log = entity.getOrAddComponent<ShipLog>();
    log.add(message, color);
}

void PlayerSpaceship::addToShipLogBy(string message, P<SpaceObject> target)
{
    // Log messages received from other ships. Friend-or-foe colors are drawn
    // from colorConfig (colors.ini).
    if (!target)
        addToShipLog(message, colorConfig.log_receive_neutral);
    else if (isFriendly(target))
        addToShipLog(message, colorConfig.log_receive_friendly);
    else if (isEnemy(target))
        addToShipLog(message, colorConfig.log_receive_enemy);
    else
        addToShipLog(message, colorConfig.log_receive_neutral);
}

void PlayerSpaceship::transferPlayersToShip(P<PlayerSpaceship> other_ship)
{
    // Don't do anything without a valid target. The target must be a
    // PlayerSpaceship.
    if (!other_ship)
        return;

    // For each player, move them to the same station on the target.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship == entity)
        {
            i->ship = other_ship->entity;
        }
    }
}

void PlayerSpaceship::transferPlayersAtPositionToShip(ECrewPosition position, P<PlayerSpaceship> other_ship)
{
    // Don't do anything without a valid target. The target must be a
    // PlayerSpaceship.
    if (!other_ship)
        return;

    // For each player, check which position they fill. If the position matches
    // the requested position, move that player. Otherwise, ignore them.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship == entity && i->crew_position[position])
        {
            i->ship = other_ship->entity;
        }
    }
}

bool PlayerSpaceship::hasPlayerAtPosition(ECrewPosition position)
{
    return PlayerInfo::hasPlayerAtPosition(entity, position);
}

void PlayerSpaceship::addCustomButton(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback, std::optional<int> order)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Button;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    //TODO: f.callback = callback;
    f.order = order.value_or(0);
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomInfo(ECrewPosition position, string name, string caption, std::optional<int> order)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Info;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    f.order = order.value_or(0);
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomMessage(ECrewPosition position, string name, string caption)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Message;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomMessageWithCallback(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Message;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    //TODO: f.callback = callback;
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::removeCustom(string name)
{
    auto csf = entity.getComponent<CustomShipFunctions>();
    if (!csf) return;
    for(auto it = csf->functions.begin(); it != csf->functions.end();)
    {
        if (it->name == name)
            it = csf->functions.erase(it);
        else
            it++;
    }
}

void PlayerSpaceship::setCommsMessage(string message)
{
    if (auto transmitter = entity.getComponent<CommsTransmitter>()) {
        // Record a new comms message to the ship's log.
        for(string line : message.split("\n"))
            addToShipLog(line, glm::u8vec4(192, 192, 255, 255));
        // Display the message in the messaging window.
        transmitter->incomming_message = message;
    }
}

void PlayerSpaceship::setEnergyLevel(float amount) {} //TODO
void PlayerSpaceship::setEnergyLevelMax(float amount) {} //TODO
float PlayerSpaceship::getEnergyLevel() { return 0.0f; } //TODO
float PlayerSpaceship::getEnergyLevelMax() { return 0.0f; } //TODO

void PlayerSpaceship::setCanDock(bool enabled)
{
    if (!enabled) {
        //TODO: Undock first!
        entity.removeComponent<DockingPort>();
    } else {
        auto& port = entity.getOrAddComponent<DockingPort>();
        //port.dock_class = ship_template->getClass();
        //port.dock_subclass = ship_template->getSubClass();
    }
}

bool PlayerSpaceship::getCanDock()
{
    return entity.hasComponent<DockingPort>();
}

ShipSystem::Type PlayerSpaceship::getBeamSystemTarget() { return ShipSystem::Type::None; /* TODO */ }
string PlayerSpaceship::getBeamSystemTargetName() { return ""; /* TODO */ }

void PlayerSpaceship::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    SpaceShip::drawOnGMRadar(renderer, position, scale, rotation, long_range);

    if (long_range)
    {
        /* TODO
        float long_radar_indicator_radius = getLongRangeRadarRange() * scale;
        float short_radar_indicator_radius = getShortRangeRadarRange() * scale;

        // Draw long-range radar radius indicator
        renderer.drawCircleOutline(position, long_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));

        // Draw short-range radar radius indicator
        renderer.drawCircleOutline(position, short_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));
        */
    }
}

string PlayerSpaceship::getExportLine()
{
    string result = "PlayerSpaceship():setTemplate(\"" + template_name + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + getScriptExportModificationsOnTemplate();
    //if (getShortRangeRadarRange() != ship_template->short_range_radar_range)
    //    result += ":setShortRangeRadarRange(" + string(getShortRangeRadarRange(), 0) + ")";
    //if (getLongRangeRadarRange() != ship_template->long_range_radar_range)
    //    result += ":setLongRangeRadarRange(" + string(getLongRangeRadarRange(), 0) + ")";
    //if (can_scan != ship_template->can_scan)
    //    result += ":setCanScan(" + string(can_scan, true) + ")";
    //if (can_hack != ship_template->can_hack)
    //    result += ":setCanHack(" + string(can_hack, true) + ")";
    //if (can_dock != ship_template->can_dock)
    //    result += ":setCanDock(" + string(can_dock, true) + ")";
    //if (can_combat_maneuver != ship_template->can_combat_maneuver)
    //    result += ":setCanCombatManeuver(" + string(can_combat_maneuver, true) + ")";
    //if (can_self_destruct != ship_template->can_self_destruct)
    //    result += ":setCanSelfDestruct(" + string(can_self_destruct, true) + ")";
    //if (can_launch_probe != ship_template->can_launch_probe)
    //    result += ":setCanLaunchProbe(" + string(can_launch_probe, true) + ")";
    //if (auto_coolant_enabled)
    //    result += ":setAutoCoolant(true)";
    //if (auto_repair_enabled)
    //    result += ":commandSetAutoRepair(true)";

    // Update power factors, only for the systems where it changed.
    /*
    for (unsigned int sys_index = 0; sys_index < SYS_COUNT; ++sys_index)
    {
        auto system = static_cast<ESystem>(sys_index);
        if (hasSystem(system))
        {
            SDL_assert(sys_index < default_system_power_factors.size());
            auto default_factor = default_system_power_factors[sys_index];
            auto current_factor = getSystemPowerFactor(system);
            auto difference = std::fabs(current_factor - default_factor) > std::numeric_limits<float>::epsilon();
            if (difference)
            {
                result += ":setSystemPowerFactor(\"" + getSystemName(system) + "\", " + string(current_factor, 1) + ")";
            }

            if (std::fabs(getSystemCoolantRate(system) - ShipSystemLegacy::default_coolant_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemCoolantRate(\"" + getSystemName(system) + "\", " + string(getSystemCoolantRate(system), 2) + ")";
            }

            if (std::fabs(getSystemHeatRate(system) - ShipSystemLegacy::default_heat_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemHeatRate(\"" + getSystemName(system) + "\", " + string(getSystemHeatRate(system), 2) + ")";
            }

            if (std::fabs(getSystemPowerRate(system) - ShipSystemLegacy::default_power_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemPowerRate(\"" + getSystemName(system) + "\", " + string(getSystemPowerRate(system), 2) + ")";
            }
        }
    }
    */

    //if (std::fabs(getEnergyShieldUsePerSecond() - default_energy_shield_use_per_second) > std::numeric_limits<float>::epsilon())
    //    result += ":setEnergyShieldUsePerSecond(" + string(getEnergyShieldUsePerSecond(), 2) + ")";

    //if (std::fabs(getEnergyWarpPerSecond() - default_energy_warp_per_second) > std::numeric_limits<float>::epsilon())
    //    result += ":setEnergyWarpPerSecond(" + string(getEnergyWarpPerSecond(), 2) + ")";
    return result;
}

void PlayerSpaceship::onProbeLaunch(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_launch = callback;
}

void PlayerSpaceship::onProbeLink(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_link = callback;
}

void PlayerSpaceship::onProbeUnlink(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_unlink = callback;
}

#include "playerSpaceship.hpp"
