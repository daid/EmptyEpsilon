#include <i18n.h>
#include "hotkeyConfig.h"
#include "preferenceManager.h"
#include "shipTemplate.h"

Keys keys;

Keys::Keys() :
    //Basic
    pause("PAUSE", "P"),
    help("HELP", "F1"),
    escape("ESCAPE", {"Escape", "Home", "Keypad 7", "AC Back"}),
    zoom_in("ZOOM_IN", {"wheel:y"}),
    zoom_out("ZOOM_OUT"),
    voice_all("VOICE_ALL", "Backspace"),
    voice_ship("VOICE_SHIP", "Tilde"),

    //General
    next_station("STATION_NEXT", "Tab"),
    prev_station("STATION_PREVIOUS"),
    station_helms("STATION_HELMS", "F2"),
    station_weapons("STATION_WEAPONS", "F3"),
    station_engineering("STATION_ENGINEERING", "F4"),
    station_science("STATION_SCIENCE", "F5"),
    station_relay("STATION_RELAY", "F5"),

    //Main screen
    mainscreen_forward("MAINSCREEN_FORWARD", "Up"),
    mainscreen_left("MAINSCREEN_LEFT", "Left"),
    mainscreen_right("MAINSCREEN_RIGHT", "Right"),
    mainscreen_back("MAINSCREEN_BACK", "Down"),
    mainscreen_target("MAINSCREEN_TARGET", "T"),
    mainscreen_tactical_radar("MAINSCREEN_TACTICAL", "Tab"),
    mainscreen_long_range_radar("MAINSCREEN_LONG_RANGE", "Q"),
    mainscreen_first_person("MAINSCREEN_FIRST_PERSON", "F"),

    //helms
    helms_increase_impulse("HELMS_IMPULSE_INCREASE", "Up"),
    helms_decrease_impulse("HELMS_IMPULSE_DECREASE", "Down"),
    helms_zero_impulse("HELMS_IMPULSE_ZERO", "Space"),
    helms_max_impulse("HELMS_IMPULSE_MAX"),
    helms_min_impulse("HELMS_IMPULSE_MIN"),
    helms_turn_left("HELMS_TURN_LEFT", "Left"),
    helms_turn_right("HELMS_TURN_RIGHT", "Right"),
    helms_warp0("HELMS_WARP0", "6"),
    helms_warp1("HELMS_WARP1", "7"),
    helms_warp2("HELMS_WARP2", "8"),
    helms_warp3("HELMS_WARP3", "9"),
    helms_warp4("HELMS_WARP4", "0"),
    helms_increase_warp("HELMS_WARP_INCREASE"),
    helms_decrease_warp("HELMS_WARP_DECREASE"),
    helms_dock_action("HELMS_DOCK_ACTION", "D"),
    helms_dock_request("HELMS_DOCK_REQUEST"),
    helms_dock_abort("HELMS_DOCK_ABORT"),
    helms_undock("HELMS_UNDOCK"),
    helms_increase_jump_distance("HELMS_JUMP_INCREASE", "RBracket"),
    helms_decrease_jump_distance("HELMS_JUMP_DECREASE", "LBracket"),
    helms_execute_jump("HELMS_JUMP_EXECUTE", "BackSlash"),
    helms_combat_left("HELMS_COMBAT_LEFT"),
    helms_combat_right("HELMS_COMBAT_RIGHT"),
    helms_combat_boost("HELMS_COMBAT_BOOST"),

    //weapons
    weapons_select_homing("WEAPONS_SELECT_HOMING", "1"),
    weapons_select_nuke("WEAPONS_SELECT_NUKE", "2"),
    weapons_select_mine("WEAPONS_SELECT_MINE", "3"),
    weapons_select_emp("WEAPONS_SELECT_EMP", "4"),
    weapons_select_hvli("WEAPONS_SELECT_HVLI", "5"),
    weapons_load_tube{{
        {"WEAPONS_LOAD_TUBE1"},
        {"WEAPONS_LOAD_TUBE2"},
        {"WEAPONS_LOAD_TUBE3"},
        {"WEAPONS_LOAD_TUBE4"},
        {"WEAPONS_LOAD_TUBE5"},
        {"WEAPONS_LOAD_TUBE6"},
        {"WEAPONS_LOAD_TUBE7"},
        {"WEAPONS_LOAD_TUBE8"},
        {"WEAPONS_LOAD_TUBE9"},
        {"WEAPONS_LOAD_TUBE10"},
        {"WEAPONS_LOAD_TUBE11"},
        {"WEAPONS_LOAD_TUBE12"},
        {"WEAPONS_LOAD_TUBE13"},
        {"WEAPONS_LOAD_TUBE14"},
        {"WEAPONS_LOAD_TUBE15"},
        {"WEAPONS_LOAD_TUBE16"}
    }},
    weapons_unload_tube{{
        {"WEAPONS_UNLOAD_TUBE1"},
        {"WEAPONS_UNLOAD_TUBE2"},
        {"WEAPONS_UNLOAD_TUBE3"},
        {"WEAPONS_UNLOAD_TUBE4"},
        {"WEAPONS_UNLOAD_TUBE5"},
        {"WEAPONS_UNLOAD_TUBE6"},
        {"WEAPONS_UNLOAD_TUBE7"},
        {"WEAPONS_UNLOAD_TUBE8"},
        {"WEAPONS_UNLOAD_TUBE9"},
        {"WEAPONS_UNLOAD_TUBE10"},
        {"WEAPONS_UNLOAD_TUBE11"},
        {"WEAPONS_UNLOAD_TUBE12"},
        {"WEAPONS_UNLOAD_TUBE13"},
        {"WEAPONS_UNLOAD_TUBE14"},
        {"WEAPONS_UNLOAD_TUBE15"},
        {"WEAPONS_UNLOAD_TUBE16"},
    }},
    weapons_fire_tube{{
        {"WEAPONS_FIRE_TUBE1"},
        {"WEAPONS_FIRE_TUBE2"},
        {"WEAPONS_FIRE_TUBE3"},
        {"WEAPONS_FIRE_TUBE4"},
        {"WEAPONS_FIRE_TUBE5"},
        {"WEAPONS_FIRE_TUBE6"},
        {"WEAPONS_FIRE_TUBE7"},
        {"WEAPONS_FIRE_TUBE8"},
        {"WEAPONS_FIRE_TUBE9"},
        {"WEAPONS_FIRE_TUBE10"},
        {"WEAPONS_FIRE_TUBE11"},
        {"WEAPONS_FIRE_TUBE12"},
        {"WEAPONS_FIRE_TUBE13"},
        {"WEAPONS_FIRE_TUBE14"},
        {"WEAPONS_FIRE_TUBE15"},
        {"WEAPONS_FIRE_TUBE16"},
    }},
    weapons_enemy_next_target("WEAPONS_TARGET_NEXT_ENEMY", "C"),
    weapons_next_target("WEAPONS_TARGET_NEXT", "Z"),
    weapons_toggle_shields("WEAPONS_SHIELDS_TOGGLE", "S"),
    weapons_enable_shields("WEAPONS_SHIELDS_ENABLE"),
    weapons_disable_shields("WEAPONS_SHIELDS_DISABLE"),
    weapons_shield_calibration_increase("WEAPONS_SHIELD_CALIBRATION_INCREASE", "Period"),
    weapons_shield_calibration_decrease("WEAPONS_SHIELD_CALIBRATION_DECREASE", "Comma"),
    weapons_shield_calibration_start("WEAPONS_SHIELD_CALIBRATION_START", "Slash"),
    weapons_beam_subsystem_target_next("WEAPONS_SUBSYSTEM_TARGET_NEXT", "Quote"),
    weapons_beam_subsystem_target_previous("WEAPONS_SUBSYSTEM_TARGET_PREVIOUS", "SemiColon"),
    weapons_beam_frequence_increase("WEAPONS_FREQUENCY_INCREASE", "M"),
    weapons_beam_frequence_decrease("WEAPONS_FREQUENCY_DECREASE", "N"),
    weapons_toggle_aim_lock("WEAPONS_AIM_LOCK_TOGGLE"),
    weapons_enable_aim_lock("WEAPONS_AIM_LOCK_ENABLE"),
    weapons_disable_aim_lock("WEAPONS_AIM_LOCK_DISABLE"),
    weapons_aim_left("WEAPONS_AIM_LEFT", "G"),
    weapons_aim_right("WEAPONS_AIM_RIGHT", "H"),

    //Science
    science_scan_object("SCIENCE_SCAN_OBJECT", "S"),
    science_select_next_scannable("SCIENCE_SELECT_NEXT_SCANNABLE", "C"),

    //Engineering
    engineering_select_reactor("ENGINEERING_SELECT_SYSTEM_REACTOR", "1"),
    engineering_select_beam_weapons("ENGINEERING_SELECT_SYSTEM_BEAM_WEAPONS", "2"),
    engineering_select_missile_system("ENGINEERING_SELECT_SYSTEM_MISSILE", "3"),
    engineering_select_maneuvering_system("ENGINEERING_SELECT_SYSTEM_MANEUVERING", "4"),
    engineering_select_impulse_system("ENGINEERING_SELECT_SYSTEM_IMPULSE", "5"),
    engineering_select_warp_system("ENGINEERING_SELECT_SYSTEM_WARP", "6"),
    engineering_select_jump_drive_system("ENGINEERING_SELECT_SYSTEM_JUMP_DRIVE", "7"),
    engineering_select_front_shield_system("ENGINEERING_SELECT_SYSTEM_FRONT_SHIELD", "8"),
    engineering_select_rear_shield_system("ENGINEERING_SELECT_SYSTEM_READ_SHIELD", "9"),
    engineering_set_power_000("ENGINEERING_POWER_000"),
    engineering_set_power_030("ENGINEERING_POWER_030"),
    engineering_set_power_050("ENGINEERING_POWER_050"),
    engineering_set_power_100("ENGINEERING_POWER_100", "Space"),
    engineering_set_power_150("ENGINEERING_POWER_150"),
    engineering_set_power_200("ENGINEERING_POWER_200"),
    engineering_set_power_250("ENGINEERING_POWER_250"),
    engineering_set_power_300("ENGINEERING_POWER_300"),
    engineering_increase_power("ENGINEERING_POWER_INCREASE", "Up"),
    engineering_decrease_power("ENGINEERING_POWER_DECREASE", "Down"),
    engineering_increase_coolant("ENGINEERING_COOLANT_INCREASE", "Left"),
    engineering_decrease_coolant("ENGINEERING_COOLANT_DECREASE", "Right"),
    engineering_next_repair_crew("ENGINEERING_REPAIR_CREW_NEXT", "Q"),
    engineering_repair_crew_up("ENGINEERING_REPAIR_CREW_UP", "W"),
    engineering_repair_crew_down("ENGINEERING_REPAIR_CREW_DOWN", "S"),
    engineering_repair_crew_left("ENGINEERING_REPAIR_CREW_LEFT", "A"),
    engineering_repair_crew_right("ENGINEERING_REPAIR_CREW_RIGHT", "D"),
    engineering_self_destruct_start("ENGINEERING_SELF_DESTRUCT_START"),
    engineering_self_destruct_confirm("ENGINEERING_SELF_DESTRUCT_CONFIRM"),
    engineering_self_destruct_cancel("ENGINEERING_SELF_DESTRUCT_CANCEL"),

    gm_delete("GM_DELETE", "Delete"),
    gm_clipboardcopy("GM_CLIPBOARD_COPY", "F5"),

    spectator_show_callsigns("SPECTATOR_SHOW_CALLSIGNS", "C")
{
}

void Keys::init()
{
    pause.setLabel(tr("hotkey_Basic", "Pause game"));
    help.setLabel(tr("hotkey_Basic", "Show in-game help"));
    escape.setLabel(tr("hotkey_Basic", "Return to ship options menu"));
    zoom_in.setLabel(tr("hotkey_Basic", "Zoom in on zoomable stations"));
    zoom_out.setLabel(tr("hotkey_Basic", "Zoom out on zoomable stations"));
    voice_all.setLabel(tr("hotkey_Basic", "Broadcast voice chat to server"));
    voice_ship.setLabel(tr("hotkey_Basic", "Broadcast voice chat to ship"));

    //General
    next_station.setLabel(tr("hotkey_General", "Switch to next crew station"));
    prev_station.setLabel(tr("hotkey_General", "Switch to previous crew station"));
    station_helms.setLabel(tr("hotkey_General", "Switch to helms station"));
    station_weapons.setLabel(tr("hotkey_General", "Switch to weapons station"));
    station_engineering.setLabel(tr("hotkey_General", "Switch to engineering station"));
    station_science.setLabel(tr("hotkey_General", "Switch to science station"));
    station_relay.setLabel(tr("hotkey_General", "Switch to relay station"));

    //Main screen
    mainscreen_forward.setLabel(tr("hotkey_MainScreen", "View forward"));
    mainscreen_left.setLabel(tr("hotkey_MainScreen", "View left"));
    mainscreen_right.setLabel(tr("hotkey_MainScreen", "View right"));
    mainscreen_back.setLabel(tr("hotkey_MainScreen", "View backward"));
    mainscreen_target.setLabel(tr("hotkey_MainScreen", "Lock view on weapons target"));
    mainscreen_tactical_radar.setLabel(tr("hotkey_MainScreen", "View tactical radar"));
    mainscreen_long_range_radar.setLabel(tr("hotkey_MainScreen", "View long-range radar"));
    mainscreen_first_person.setLabel(tr("hotkey_MainScreen", "Toggle first-person view"));

    //helms
    helms_increase_impulse.setLabel(tr("hotkey_Helms", "Increase impulse"));
    helms_decrease_impulse.setLabel(tr("hotkey_Helms", "Decrease impulse"));
    helms_zero_impulse.setLabel(tr("hotkey_Helms", "Zero impulse"));
    helms_max_impulse.setLabel(tr("hotkey_Helms", "Max impulse"));
    helms_min_impulse.setLabel(tr("hotkey_Helms", "Max reverse impulse"));
    helms_turn_left.setLabel(tr("hotkey_Helms", "Turn left"));
    helms_turn_right.setLabel(tr("hotkey_Helms", "Turn right"));
    helms_warp0.setLabel(tr("hotkey_Helms", "Warp off"));
    helms_warp1.setLabel(tr("hotkey_Helms", "Warp 1"));
    helms_warp2.setLabel(tr("hotkey_Helms", "Warp 2"));
    helms_warp3.setLabel(tr("hotkey_Helms", "Warp 3"));
    helms_warp4.setLabel(tr("hotkey_Helms", "Warp 4"));
    helms_increase_warp.setLabel(tr("hotkey_Helms", "Increase Warp"));
    helms_decrease_warp.setLabel(tr("hotkey_Helms", "Decrease Warp"));
    helms_dock_action.setLabel(tr("hotkey_Helms", "Dock request/abort/undock"));
    helms_dock_request.setLabel(tr("hotkey_Helms", "Initiate docking"));
    helms_dock_abort.setLabel(tr("hotkey_Helms", "Abort docking"));
    helms_undock.setLabel(tr("hotkey_Helms", "Undock"));
    helms_increase_jump_distance.setLabel(tr("hotkey_Helms", "Increase jump distance"));
    helms_decrease_jump_distance.setLabel(tr("hotkey_Helms", "Decrease jump distance"));
    helms_execute_jump.setLabel(tr("hotkey_Helms", "Initiate jump"));
    helms_combat_left.setLabel(tr("hotkey_Helms", "Combat boost left"));
    helms_combat_right.setLabel(tr("hotkey_Helms", "Combat boost right"));
    helms_combat_boost.setLabel(tr("hotkey_Helms", "Combat boost forwards"));

    //weapons
    weapons_select_homing.setLabel(tr("hotkey_Weapons", "Select homing"));
    weapons_select_nuke.setLabel(tr("hotkey_Weapons", "Select nuke"));
    weapons_select_mine.setLabel(tr("hotkey_Weapons", "Select mine"));
    weapons_select_emp.setLabel(tr("hotkey_Weapons", "Select EMP"));
    weapons_select_hvli.setLabel(tr("hotkey_Weapons", "Select HVLI"));
    for(auto n = 0u; n < weapons_load_tube.size(); n++)
    {
        weapons_load_tube[n].setLabel(tr("hotkey_Weapons", "Load tube {number}").format({{"number", string(n+1)}}));
        weapons_unload_tube[n].setLabel(tr("hotkey_Weapons", "Unload tube {number}").format({{"number", string(n+1)}}));
        weapons_fire_tube[n].setLabel(tr("hotkey_Weapons", "Fire tube {number}").format({{"number", string(n+1)}}));
    }
    weapons_enemy_next_target.setLabel(tr("hotkey_Weapons", "Select next hostile target"));
    weapons_next_target.setLabel(tr("hotkey_Weapons", "Select next target (any)"));
    weapons_toggle_shields.setLabel(tr("hotkey_Weapons", "Toggle shields"));
    weapons_enable_shields.setLabel(tr("hotkey_Weapons", "Enable shields"));
    weapons_disable_shields.setLabel(tr("hotkey_Weapons", "Disable shields"));
    weapons_shield_calibration_increase.setLabel(tr("hotkey_Weapons", "Increase shield frequency target"));
    weapons_shield_calibration_decrease.setLabel(tr("hotkey_Weapons", "Decrease shield frequency target"));
    weapons_shield_calibration_start.setLabel(tr("hotkey_Weapons", "Start shield calibration"));
    weapons_beam_subsystem_target_next.setLabel(tr("hotkey_Weapons", "Next beam subsystem target type"));
    weapons_beam_subsystem_target_previous.setLabel(tr("hotkey_Weapons", "Previous beam subsystem target type"));
    weapons_beam_frequence_increase.setLabel(tr("hotkey_Weapons", "Increase beam frequency"));
    weapons_beam_frequence_decrease.setLabel(tr("hotkey_Weapons", "Decrease beam frequency"));
    weapons_toggle_aim_lock.setLabel(tr("hotkey_Weapons", "Toggle missile aim lock"));
    weapons_enable_aim_lock.setLabel(tr("hotkey_Weapons", "Enable missile aim lock"));
    weapons_disable_aim_lock.setLabel(tr("hotkey_Weapons", "Disable"));
    weapons_aim_left.setLabel(tr("hotkey_Weapons", "Turn missile aim to the left"));
    weapons_aim_right.setLabel(tr("hotkey_Weapons", "Turn missile aim to the right"));

    //Science
    science_scan_object.setLabel(tr("hotkey_Science", "Scan object"));
    science_select_next_scannable.setLabel(tr("hotkey_Science", "Select next scannable object"));

    //Engineering
    engineering_select_reactor.setLabel(tr("hotkey_Engineering", "Select reactor system"));
    engineering_select_beam_weapons.setLabel(tr("hotkey_Engineering", "Select beam weapon system"));
    engineering_select_missile_system.setLabel(tr("hotkey_Engineering", "Select missile weapon system"));
    engineering_select_maneuvering_system.setLabel(tr("hotkey_Engineering", "Select maneuvering system"));
    engineering_select_impulse_system.setLabel(tr("hotkey_Engineering", "Select impulse system"));
    engineering_select_warp_system.setLabel(tr("hotkey_Engineering", "Select warp system"));
    engineering_select_jump_drive_system.setLabel(tr("hotkey_Engineering", "Select jump drive system"));
    engineering_select_front_shield_system.setLabel(tr("hotkey_Engineering", "Select front shields system"));
    engineering_select_rear_shield_system.setLabel(tr("hotkey_Engineering", "Select rear shields system"));
    engineering_set_power_000.setLabel(tr("hotkey_Engineering", "Set system power to 0%"));
    engineering_set_power_030.setLabel(tr("hotkey_Engineering", "Set system power to 30%"));
    engineering_set_power_050.setLabel(tr("hotkey_Engineering", "Set system power to 50%"));
    engineering_set_power_100.setLabel(tr("hotkey_Engineering", "Set system power to 100%"));
    engineering_set_power_150.setLabel(tr("hotkey_Engineering", "Set system power to 150%"));
    engineering_set_power_200.setLabel(tr("hotkey_Engineering", "Set system power to 200%"));
    engineering_set_power_250.setLabel(tr("hotkey_Engineering", "Set system power to 250%"));
    engineering_set_power_300.setLabel(tr("hotkey_Engineering", "Set system power to 300%"));
    engineering_increase_power.setLabel(tr("hotkey_Engineering", "Increase system power"));
    engineering_decrease_power.setLabel(tr("hotkey_Engineering", "Decrease system power"));
    engineering_increase_coolant.setLabel(tr("hotkey_Engineering", "Increase system coolant"));
    engineering_decrease_coolant.setLabel(tr("hotkey_Engineering", "Decrease system coolant"));
    engineering_next_repair_crew.setLabel(tr("hotkey_Engineering", "Next repair crew"));
    engineering_repair_crew_up.setLabel(tr("hotkey_Engineering", "Crew move up"));
    engineering_repair_crew_down.setLabel(tr("hotkey_Engineering", "Crew move down"));
    engineering_repair_crew_left.setLabel(tr("hotkey_Engineering", "Crew move left"));
    engineering_repair_crew_right.setLabel(tr("hotkey_Engineering", "Crew move right"));
    engineering_self_destruct_start.setLabel(tr("hotkey_Engineering", "Start self-destruct"));
    engineering_self_destruct_confirm.setLabel(tr("hotkey_Engineering", "Confirm self-destruct"));
    engineering_self_destruct_cancel.setLabel(tr("hotkey_Engineering", "Cancel self-destruct"));

    //GM
    gm_delete.setLabel(tr("hotkey_GM", "Delete"));
    gm_clipboardcopy.setLabel(tr("hotkey_GM", "Copy to clipboard"));

    //Various
    spectator_show_callsigns.setLabel(tr("hotkey_various", "Show callsigns (spectator)"));
}


HotkeyConfig::HotkeyConfig()
{  // this list includes all Hotkeys and their standard configuration
    newCategory("BASIC", tr("hotkey_menu", "Basic")); // these Items should all have predefined values
    newKey("PAUSE", std::make_tuple(tr("hotkey_Basic", "Pause game"), "P"));
    newKey("HELP", std::make_tuple(tr("hotkey_Basic", "Show in-game help"), "F1"));
    newKey("ESCAPE", std::make_tuple(tr("hotkey_Basic", "Return to ship options menu"), "Escape"));
    newKey("HOME", std::make_tuple(tr("hotkey_Basic", "Return to ship options menu"), "Home"));  // Remove this item as it does the same as Escape?
    newKey("VOICE_CHAT_ALL", std::make_tuple(tr("hotkey_Basic", "Broadcast voice chat to server"), "Backspace"));
    newKey("VOICE_CHAT_SHIP", std::make_tuple(tr("hotkey_Basic", "Broadcast voice chat to ship"), "Tilde"));

    newCategory("GENERAL", tr("hotkey_menu", "General"));
    newKey("NEXT_STATION", std::make_tuple(tr("hotkey_General", "Switch to next crew station"), "Tab"));
    newKey("PREV_STATION", std::make_tuple(tr("hotkey_General", "Switch to previous crew station"), ""));
    newKey("STATION_HELMS", std::make_tuple(tr("hotkey_General", "Switch to helms station"), "F2"));
    newKey("STATION_WEAPONS", std::make_tuple(tr("hotkey_General", "Switch to weapons station"), "F3"));
    newKey("STATION_ENGINEERING", std::make_tuple(tr("hotkey_General", "Switch to engineering station"), "F4"));
    newKey("STATION_SCIENCE", std::make_tuple(tr("hotkey_General", "Switch to science station"), "F5"));
    newKey("STATION_RELAY", std::make_tuple(tr("hotkey_General", "Switch to relay station"), "F6"));

    newCategory("MAIN_SCREEN", tr("hotkey_menu", "Main Screen"));
    newKey("VIEW_FORWARD", std::make_tuple(tr("hotkey_MainScreen", "View forward"), "Up"));
    newKey("VIEW_LEFT", std::make_tuple(tr("hotkey_MainScreen", "View left"), "Left"));
    newKey("VIEW_RIGHT", std::make_tuple(tr("hotkey_MainScreen", "View right"), "Right"));
    newKey("VIEW_BACK", std::make_tuple(tr("hotkey_MainScreen", "View backward"), "Down"));
    newKey("VIEW_TARGET", std::make_tuple(tr("hotkey_MainScreen", "Lock view on weapons target"), "T"));
    newKey("TACTICAL_RADAR", std::make_tuple(tr("hotkey_MainScreen", "View tactical radar"), "Tab"));
    newKey("LONG_RANGE_RADAR", std::make_tuple(tr("hotkey_MainScreen", "View long-range radar"), "Q"));
    newKey("FIRST_PERSON", std::make_tuple(tr("hotkey_MainScreen", "Toggle first-person view"), "F"));

    // - Single Pilot and Tactical use:
    //   - Helms TURN_LEFT and _RIGHT, DOCK_* and UNDOCK, *_IMPULSE, *_JUMP,
    //     and WARP_*.
    //   - Weapons NEXT_ENEMY_TARGET, NEXT_TARGET, AIM_MISSILE_LEFT and _RIGHT,
    //     *_AIM_LOCK, COMBAT_*, SELECT_MISSILE_*, *_TUBE_*, SHIELD_CAL_*,
    //     and *_SHIELDS.
    // - Tactical also uses:
    //   - Weapons BEAM_FREQUENCY_*, BEAM_SUBSYSTEM_TARGET_*
    // - Operations uses Science hotkeys.

    newCategory("HELMS", tr("hotkey_menu", "Helms"));
    newKey("INC_IMPULSE", std::make_tuple(tr("hotkey_Helms", "Increase impulse"), "Up"));
    newKey("DEC_IMPULSE", std::make_tuple(tr("hotkey_Helms", "Decrease impulse"), "Down"));
    newKey("ZERO_IMPULSE", std::make_tuple(tr("hotkey_Helms", "Zero impulse"), "Space"));
    newKey("MAX_IMPULSE", std::make_tuple(tr("hotkey_Helms", "Max impulse"), ""));
    newKey("MIN_IMPULSE", std::make_tuple(tr("hotkey_Helms", "Max reverse impulse"), ""));
    newKey("TURN_LEFT", std::make_tuple(tr("hotkey_Helms", "Turn left"), "Left"));
    newKey("TURN_RIGHT", std::make_tuple(tr("hotkey_Helms", "Turn right"), "Right"));
    newKey("WARP_0", std::make_tuple(tr("hotkey_Helms", "Warp off"), "Num6"));
    newKey("WARP_1", std::make_tuple(tr("hotkey_Helms", "Warp 1"), "Num7"));
    newKey("WARP_2", std::make_tuple(tr("hotkey_Helms", "Warp 2"), "Num8"));
    newKey("WARP_3", std::make_tuple(tr("hotkey_Helms", "Warp 3"), "Num9"));
    newKey("WARP_4", std::make_tuple(tr("hotkey_Helms", "Warp 4"), "Num0"));
    newKey("INC_WARP", std::make_tuple(tr("hotkey_Helms", "Increase Warp"), ""));
    newKey("DEC_WARP", std::make_tuple(tr("hotkey_Helms", "Decrease Warp"), ""));
    newKey("DOCK_ACTION", std::make_tuple(tr("hotkey_Helms", "Dock request/abort/undock"), "D"));
    newKey("DOCK_REQUEST", std::make_tuple(tr("hotkey_Helms", "Initiate docking"), ""));
    newKey("DOCK_ABORT", std::make_tuple(tr("hotkey_Helms", "Abort docking"), ""));
    newKey("UNDOCK", std::make_tuple(tr("hotkey_Helms", "Undock"), "D"));
    newKey("INC_JUMP", std::make_tuple(tr("hotkey_Helms", "Increase jump distance"), "RBracket"));
    newKey("DEC_JUMP", std::make_tuple(tr("hotkey_Helms", "Decrease jump distance"), "LBracket"));
    newKey("JUMP", std::make_tuple(tr("hotkey_Helms", "Initiate jump"), "BackSlash"));
    //newKey("COMBAT_LEFT", "Combat maneuver left");
    //newKey("COMBAT_RIGHT", "Combat maneuver right");
    //newKey("COMBAT_BOOST", "Combat maneuver boost");

    newCategory("WEAPONS", tr("hotkey_menu", "Weapons"));
    newKey("SELECT_MISSILE_TYPE_HOMING", std::make_tuple(tr("hotkey_Weapons", "Select homing"), "Num1"));
    newKey("SELECT_MISSILE_TYPE_NUKE", std::make_tuple(tr("hotkey_Weapons", "Select nuke"), "Num2"));
    newKey("SELECT_MISSILE_TYPE_MINE", std::make_tuple(tr("hotkey_Weapons", "Select mine"), "Num3"));
    newKey("SELECT_MISSILE_TYPE_EMP", std::make_tuple(tr("hotkey_Weapons", "Select EMP"), "Num4"));
    newKey("SELECT_MISSILE_TYPE_HVLI", std::make_tuple(tr("hotkey_Weapons", "Select HVLI"), "Num5"));
    for(int n = 0; n < max_weapon_tubes; n++)
    {
        newKey(std::string("LOAD_TUBE_") + string(n+1), std::make_tuple(std::string(tr("hotkey_Weapons", "Load tube {number}").format({{"number", string(n+1)}})), ""));
    }
    for(int n = 0; n < max_weapon_tubes; n++)
    {
        newKey(std::string("UNLOAD_TUBE_") + string(n+1), std::make_tuple(std::string(tr("hotkey_Weapons", "Unload tube {number}").format({{"number", string(n+1)}})), ""));
    }
    for(int n = 0; n < max_weapon_tubes; n++)
    {
        newKey(std::string("FIRE_TUBE_") + string(n+1), std::make_tuple(std::string(tr("hotkey_Weapons", "Fire tube {number}").format({{"number", string(n+1)}})), ""));
    }
    newKey("NEXT_ENEMY_TARGET", std::make_tuple(tr("hotkey_Weapons", "Select next hostile target"), "C"));
    newKey("NEXT_TARGET", std::make_tuple(tr("hotkey_Weapons", "Select next target (any)"), "Z"));
    newKey("TOGGLE_SHIELDS", std::make_tuple(tr("hotkey_Weapons", "Toggle shields"), "S"));
    newKey("ENABLE_SHIELDS", std::make_tuple(tr("hotkey_Weapons", "Enable shields"), ""));
    newKey("DISABLE_SHIELDS", std::make_tuple(tr("hotkey_Weapons", "Disable shields"), ""));
    newKey("SHIELD_CAL_INC", std::make_tuple(tr("hotkey_Weapons", "Increase shield frequency target"), "Period"));
    newKey("SHIELD_CAL_DEC", std::make_tuple(tr("hotkey_Weapons", "Decrease shield frequency target"), "Comma"));
    newKey("SHIELD_CAL_START", std::make_tuple(tr("hotkey_Weapons", "Start shield calibration"), "Slash"));
    newKey("BEAM_SUBSYSTEM_TARGET_NEXT", std::make_tuple(tr("hotkey_Weapons", "Next beam subsystem target type"), "Quote"));
    newKey("BEAM_SUBSYSTEM_TARGET_PREV", std::make_tuple(tr("hotkey_Weapons", "Previous beam subsystem target type"), "SemiColon"));
    newKey("BEAM_FREQUENCY_INCREASE", std::make_tuple(tr("hotkey_Weapons", "Increase beam frequency"), "M"));
    newKey("BEAM_FREQUENCY_DECREASE", std::make_tuple(tr("hotkey_Weapons", "Decrease beam frequency"), "N"));
    newKey("TOGGLE_AIM_LOCK", std::make_tuple(tr("hotkey_Weapons", "Toggle missile aim lock"), "B"));
    newKey("ENABLE_AIM_LOCK", std::make_tuple(tr("hotkey_Weapons", "Enable missile aim lock"), ""));
    newKey("DISABLE_AIM_LOCK", std::make_tuple(tr("hotkey_Weapons", "Disable missile aim lock"), ""));
    newKey("AIM_MISSILE_LEFT", std::make_tuple(tr("hotkey_Weapons", "Turn missile aim to the left"), "G"));
    newKey("AIM_MISSILE_RIGHT", std::make_tuple(tr("hotkey_Weapons", "Turn missile aim to the right"), "H"));

    newCategory("SCIENCE", tr("hotkey_menu", "Science"));
    newKey("SCAN_OBJECT", std::make_tuple(tr("hotkey_Science", "Scan object"), "S"));
    newKey("NEXT_SCANNABLE_OBJECT", std::make_tuple(tr("hotkey_Science", "Select next scannable object"), "C"));

    // Engineering functions should not overlap with other stations'.
    newCategory("ENGINEERING", tr("hotkey_menu", "Engineering"));
    newKey("SELECT_REACTOR", std::make_tuple(tr("hotkey_Engineering", "Select reactor system"), "Num1"));
    newKey("SELECT_BEAM_WEAPONS", std::make_tuple(tr("hotkey_Engineering", "Select beam weapon system"), "Num2"));
    newKey("SELECT_MISSILE_SYSTEM", std::make_tuple(tr("hotkey_Engineering", "Select missile weapon system"), "Num3"));
    newKey("SELECT_MANEUVER", std::make_tuple(tr("hotkey_Engineering", "Select maneuvering system"), "Num4"));
    newKey("SELECT_IMPULSE", std::make_tuple(tr("hotkey_Engineering", "Select impulse system"), "Num5"));
    newKey("SELECT_WARP", std::make_tuple(tr("hotkey_Engineering", "Select warp system"), "Num6"));
    newKey("SELECT_JUMP_DRIVE", std::make_tuple(tr("hotkey_Engineering", "Select jump drive system"), "Num7"));
    newKey("SELECT_FRONT_SHIELDS", std::make_tuple(tr("hotkey_Engineering", "Select front shields system"), "Num8"));
    newKey("SELECT_REAR_SHIELDS", std::make_tuple(tr("hotkey_Engineering", "Select rear shields system"), "Num9"));
    newKey("SET_POWER_000", std::make_tuple(tr("hotkey_Engineering", "Set system power to 0%"), ""));
    newKey("SET_POWER_030", std::make_tuple(tr("hotkey_Engineering", "Set system power to 30%"), ""));
    newKey("SET_POWER_050", std::make_tuple(tr("hotkey_Engineering", "Set system power to 50%"), ""));
    newKey("SET_POWER_100", std::make_tuple(tr("hotkey_Engineering", "Set system power to 100%"), "Space"));
    newKey("SET_POWER_150", std::make_tuple(tr("hotkey_Engineering", "Set system power to 150%"), ""));
    newKey("SET_POWER_200", std::make_tuple(tr("hotkey_Engineering", "Set system power to 200%"), ""));
    newKey("SET_POWER_250", std::make_tuple(tr("hotkey_Engineering", "Set system power to 250%"), ""));
    newKey("SET_POWER_300", std::make_tuple(tr("hotkey_Engineering", "Set system power to 300%"), ""));
    newKey("INCREASE_POWER", std::make_tuple(tr("hotkey_Engineering", "Increase system power"), "Up"));
    newKey("DECREASE_POWER", std::make_tuple(tr("hotkey_Engineering", "Decrease system power"), "Down"));
    newKey("INCREASE_COOLANT", std::make_tuple(tr("hotkey_Engineering", "Increase system coolant"), "Right"));
    newKey("DECREASE_COOLANT", std::make_tuple(tr("hotkey_Engineering", "Decrease system coolant"), "Left"));
    newKey("NEXT_REPAIR_CREW", std::make_tuple(tr("hotkey_Engineering", "Next repair crew"), "Q"));
    newKey("REPAIR_CREW_MOVE_UP", std::make_tuple(tr("hotkey_Engineering", "Crew move up"), "W"));
    newKey("REPAIR_CREW_MOVE_DOWN", std::make_tuple(tr("hotkey_Engineering", "Crew move down"), "S"));
    newKey("REPAIR_CREW_MOVE_LEFT", std::make_tuple(tr("hotkey_Engineering", "Crew move left"), "A"));
    newKey("REPAIR_CREW_MOVE_RIGHT", std::make_tuple(tr("hotkey_Engineering", "Crew move right"), "D"));
    newKey("SELF_DESTRUCT_START", std::make_tuple(tr("hotkey_Engineering", "Start self-destruct"), ""));
    newKey("SELF_DESTRUCT_CONFIRM", std::make_tuple(tr("hotkey_Engineering", "Confirm self-destruct"), ""));
    newKey("SELF_DESTRUCT_CANCEL", std::make_tuple(tr("hotkey_Engineering", "Cancel self-destruct"), ""));
}

static std::vector<std::pair<string, SDL_Keycode> > sdl_key_names = {
    {"A", SDLK_a},
    {"B", SDLK_b},
    {"C", SDLK_c},
    {"D", SDLK_d},
    {"E", SDLK_e},
    {"F", SDLK_f},
    {"G", SDLK_g},
    {"H", SDLK_h},
    {"I", SDLK_i},
    {"J", SDLK_j},
    {"K", SDLK_k},
    {"L", SDLK_l},
    {"M", SDLK_m},
    {"N", SDLK_n},
    {"O", SDLK_o},
    {"P", SDLK_p},
    {"Q", SDLK_q},
    {"R", SDLK_r},
    {"S", SDLK_s},
    {"T", SDLK_t},
    {"U", SDLK_u},
    {"V", SDLK_v},
    {"W", SDLK_w},
    {"X", SDLK_x},
    {"Y", SDLK_y},
    {"Z", SDLK_z},
    {"Num0", SDLK_0},
    {"Num1", SDLK_1},
    {"Num2", SDLK_2},
    {"Num3", SDLK_3},
    {"Num4", SDLK_4},
    {"Num5", SDLK_5},
    {"Num6", SDLK_6},
    {"Num7", SDLK_7},
    {"Num8", SDLK_8},
    {"Num9", SDLK_9},
    {"Escape", SDLK_ESCAPE},
    {"LControl", SDLK_LCTRL},
    {"LShift", SDLK_LSHIFT},
    {"LAlt", SDLK_LALT},
    {"LSystem", SDLK_LGUI},
    {"RControl", SDLK_RCTRL},
    {"RShift", SDLK_RSHIFT},
    {"RAlt", SDLK_RALT},
    {"RSystem", SDLK_RGUI},
    {"Menu", SDLK_MENU},
    {"LBracket", SDLK_LEFTBRACKET},
    {"RBracket", SDLK_RIGHTBRACKET},
    {"SemiColon", SDLK_SEMICOLON},
    {"Comma", SDLK_COMMA},
    {"Period", SDLK_PERIOD},
    {"Quote", SDLK_QUOTE},
    {"Slash", SDLK_SLASH},
    {"BackSlash", SDLK_BACKSLASH},
    {"Tilde", SDLK_BACKQUOTE},
    {"Equal", SDLK_EQUALS},
    {"Dash", SDLK_MINUS},
    {"Space", SDLK_SPACE},
    {"Return", SDLK_RETURN},
    {"BackSpace", SDLK_BACKSPACE},
    {"Tab", SDLK_TAB},
    {"PageUp", SDLK_PAGEUP},
    {"PageDown", SDLK_PAGEDOWN},
    {"End", SDLK_END},
    {"Home", SDLK_HOME},
    {"Insert", SDLK_INSERT},
    {"Delete", SDLK_DELETE},
    {"Add", SDLK_KP_PLUS},
    {"Subtract", SDLK_KP_MINUS},
    {"Multiply", SDLK_KP_MULTIPLY},
    {"Divide", SDLK_KP_DIVIDE},
    {"Left", SDLK_LEFT},
    {"Right", SDLK_RIGHT},
    {"Up", SDLK_UP},
    {"Down", SDLK_DOWN},
    {"Numpad0", SDLK_KP_0},
    {"Numpad1", SDLK_KP_1},
    {"Numpad2", SDLK_KP_2},
    {"Numpad3", SDLK_KP_3},
    {"Numpad4", SDLK_KP_4},
    {"Numpad5", SDLK_KP_5},
    {"Numpad6", SDLK_KP_6},
    {"Numpad7", SDLK_KP_7},
    {"Numpad8", SDLK_KP_8},
    {"Numpad9", SDLK_KP_9},
    {"F1", SDLK_F1},
    {"F2", SDLK_F2},
    {"F3", SDLK_F3},
    {"F4", SDLK_F4},
    {"F5", SDLK_F5},
    {"F6", SDLK_F6},
    {"F7", SDLK_F7},
    {"F8", SDLK_F8},
    {"F9", SDLK_F9},
    {"F10", SDLK_F10},
    {"F11", SDLK_F11},
    {"F12", SDLK_F12},
    {"F13", SDLK_F13},
    {"F14", SDLK_F14},
    {"F15", SDLK_F15},
    {"Pause", SDLK_PAUSE},

};

string HotkeyConfig::getStringForKey(SDL_Keycode key) const
{
    for(const auto& key_name : sdl_key_names)
    {
        if (key_name.second == key)
        {
            return key_name.first;
        }
    }

    return "";
}

HotkeyConfig& HotkeyConfig::get()
{
    static HotkeyConfig hotkeys;
    return hotkeys;
}

void HotkeyConfig::load()
{
    for(HotkeyConfigCategory& cat : categories)
    {
        for(HotkeyConfigItem& item : cat.hotkeys)
        {
            string key_config = PreferencesManager::get(std::string("HOTKEY.") + cat.key + "." + item.key, std::get<1>(item.value));
            item.load(key_config);
            item.value = std::make_tuple(std::get<0>(item.value), key_config);
        }
    }
}

std::vector<HotkeyResult> HotkeyConfig::getHotkey(const SDL_KeyboardEvent& key) const
{
    constexpr auto mod_mask = (KMOD_CTRL | KMOD_ALT | KMOD_SHIFT | KMOD_GUI);
    std::vector<HotkeyResult> results;
    for(const HotkeyConfigCategory& cat : categories)
    {
        for(const HotkeyConfigItem& item : cat.hotkeys)
        {
            if (item.hotkey.keysym.sym == key.keysym.sym && item.hotkey.keysym.mod == (key.keysym.mod & mod_mask))
            {
                results.emplace_back(cat.key, item.key);
            }
        }
    }
    return results;
}

void HotkeyConfig::newCategory(const string& key, const string& name)
{
    categories.emplace_back(HotkeyConfigCategory{ key, name, {} });
}

void HotkeyConfig::newKey(const string& key, const std::tuple<string, string>& value)
{
    assert(!categories.empty());

    if (!categories.empty())
        categories.back().hotkeys.emplace_back(key, value);
}

std::vector<string> HotkeyConfig::getCategories() const
{
    // Initialize return value.
    std::vector<string> ret;
    ret.reserve(categories.size());

    // Add each category to the return value.
    for(const HotkeyConfigCategory& cat : categories)
    {
        ret.emplace_back(cat.name);
    }

    return ret;
}

std::vector<std::pair<string, string>> HotkeyConfig::listHotkeysByCategory(const string& hotkey_category) const
{
    std::vector<std::pair<string, string>> ret;

    for(const HotkeyConfigCategory& cat : categories)
    {
        if (cat.name == hotkey_category)
        {
            for(const HotkeyConfigItem& item : cat.hotkeys)
            {
                for(auto key_name : sdl_key_names)
                {
                    if (key_name.second == item.hotkey.keysym.sym)
                    {
                        string keyModifier = "";
                        if (item.hotkey.keysym.mod & KMOD_SHIFT) {
                            keyModifier = "Shift+";
                        } else if (item.hotkey.keysym.mod & KMOD_CTRL) {
                            keyModifier = "Ctrl+";
                        } else if (item.hotkey.keysym.mod & KMOD_ALT){
                            keyModifier = "Alt+";
                        }
                        ret.push_back({std::get<0>(item.value), keyModifier + key_name.first});
                    }
                }
            }
        }
    }

    return ret;
}

std::vector<std::pair<string, string>> HotkeyConfig::listAllHotkeysByCategory(const string& hotkey_category) const
{
    std::vector<std::pair<string, string>> ret;

    for(const HotkeyConfigCategory& cat : categories)
    {
        if (cat.name == hotkey_category)
        {
            for(const HotkeyConfigItem& item : cat.hotkeys)
            {
                ret.push_back({std::get<0>(item.value), std::get<1>(item.value)});
            }
        }
    }

    return ret;
}

SDL_Keycode HotkeyConfig::getKeyByHotkey(const string& hotkey_category, const string& hotkey_name) const
{
    for(const HotkeyConfigCategory& cat : categories)
    {
        if (cat.key == hotkey_category)
        {
            for(const HotkeyConfigItem& item : cat.hotkeys)
            {
                if (item.key == hotkey_name)
                {
                    return item.hotkey.keysym.sym;
                }
            }
        }
    }

    LOG(WARNING) << "Requested an SFML Key from hotkey " << hotkey_category << ", " << hotkey_name << ", but none was found.";
    return SDLK_UNKNOWN;
}

HotkeyConfigItem::HotkeyConfigItem(const string& key, const std::tuple<string, string>& value)
    :key{key}, value{value}
{
    hotkey.keysym.sym = SDLK_UNKNOWN;
    hotkey.keysym.mod = 0;
}

void HotkeyConfigItem::load(const string& key_config)
{
    for(const string& config : key_config.split(";"))
    {
        if (config == "[alt]")
            hotkey.keysym.mod |= KMOD_ALT;
        else if (config == "[control]")
            hotkey.keysym.mod |= KMOD_CTRL;
        else if (config == "[shift]")
            hotkey.keysym.mod |= KMOD_SHIFT;
        else if (config == "[system]")
            hotkey.keysym.mod |= KMOD_GUI;
        else
        {
            for(auto key_name : sdl_key_names)
            {
                if (key_name.first.lower() == config.lower())
                {
                    hotkey.keysym.sym = key_name.second;
                    break;
                }
            }
        }
    }
}

bool HotkeyConfig::setHotkey(const std::string& work_cat, const std::pair<string,string>& key, const string& new_value)
{
    // test if new_value is part of the sfml_list
    for (const auto& sfml_key : sdl_key_names)
    {
        if ((sfml_key.first.lower() == new_value.lower()) || new_value == "")
        {
            for (HotkeyConfigCategory &cat : categories)
            {
                if (cat.name == work_cat)
                {
                    for (HotkeyConfigItem &item : cat.hotkeys)
                    {
                        if (key.first == std::get<0>(item.value))
                        {
                            item.load(new_value);
                            item.value = std::make_tuple(std::get<0>(item.value), new_value);

                            PreferencesManager::set(std::string("HOTKEY.") + cat.key + "." + item.key, std::get<1>(item.value));

                            return true;
                        }
                    }
                }
            }
        }
    }

    return false;
}
