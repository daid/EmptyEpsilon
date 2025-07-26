#include <i18n.h>
#include "hotkeyConfig.h"
#include "preferenceManager.h"

Keys keys;
extern sp::io::Keybinding fullscreen_key;

// Cinematic Keys
Keys::CinematicKeys::CinematicKeys() :
    toggle_ui("CINEMATIC_TOGGLE_UI", "H"),
    lock_camera("CINEMATIC_LOCK_CAMERA", "L"),
    cycle_camera("CINEMATIC_CYCLE_CAMERA", "C"),
    previous_player_ship("CINEMATIC_PREVIOUS_PLAYER_SHIP", "J"),
    next_player_ship("CINEMATIC_NEXT_PLAYER_SHIP", "K"),
    move_forward("CINEMATIC_MOVE_FORWARD", "W"),
    move_backward("CINEMATIC_MOVE_BACKWARD", "S"),
    strafe_left("CINEMATIC_STRAFE_LEFT", "A"),
    strafe_right("CINEMATIC_STRAFE_RIGHT", "D"),
    move_up("CINEMATIC_MOVE_UP", "R"),
    move_down("CINEMATIC_MOVE_DOWN", "F"),
    rotate_left("CINEMATIC_TILT_LEFT", "Left"),
    rotate_right("CINEMATIC_TILT_RIGHT", "Right"),
    tilt_down("CINEMATIC_TILT_DOWN", "Down"),
    tilt_up("CINEMATIC_TILT_UP", "Up")
{}

void Keys::CinematicKeys::init()
{
    const auto localized_category = tr("hotkey_menu", "Cinematic View");
    toggle_ui.setLabel(localized_category, tr("hotkey_Cinematic", "Toggle UI"));
    lock_camera.setLabel(localized_category, tr("hotkey_Cinematic", "Camera lock"));
    cycle_camera.setLabel(localized_category, tr("hotkey_Cinematic", "Camera cycle"));
    previous_player_ship.setLabel(localized_category, tr("hotkey_Cinematic", "Cycle previous player ship"));
    next_player_ship.setLabel(localized_category, tr("hotkey_Cinematic", "Cycle next player ship"));
    move_forward.setLabel(localized_category, tr("hotkey_Cinematic", "Move forward"));
    move_backward.setLabel(localized_category, tr("hotkey_Cinematic", "Move backward"));
    strafe_left.setLabel(localized_category, tr("hotkey_Cinematic", "Strafe left"));
    strafe_right.setLabel(localized_category, tr("hotkey_Cinematic", "Strafe right"));
    move_up.setLabel(localized_category, tr("hotkey_Cinematic", "Move up"));
    move_down.setLabel(localized_category, tr("hotkey_Cinematic", "Move down"));
    rotate_left.setLabel(localized_category, tr("hotkey_Cinematic", "Rotate left"));
    rotate_right.setLabel(localized_category, tr("hotkey_Cinematic", "Rotate right"));
    tilt_down.setLabel(localized_category, tr("hotkey_Cinematic", "Tilt down"));
    tilt_up.setLabel(localized_category, tr("hotkey_Cinematic", "Tilt up"));
}

Keys::TopDownKeys::TopDownKeys() :
    toggle_ui("TOPDOWN_TOGGLE_UI", "H"),
    lock_camera("TOPDOWN_LOCK_CAMERA", "L"),
    previous_player_ship("TOPDOWN_PREVIOUS_PLAYER_SHIP", "J"),
    next_player_ship("TOPDOWN_NEXT_PLAYER_SHIP", "K"),
    pan_up("TOPDOWN_PAN_UP", "W"),
    pan_down("TOPDOWN_PAN_DOWN", "S"),
    pan_left("TOPDOWN_PAN_LEFT", "A"),
    pan_right("TOPDOWN_PAN_RIGHT", "D")
{}

void Keys::TopDownKeys::init()
{
    const auto localized_category = tr("hotkey_menu", "Top-down View");
    toggle_ui.setLabel(localized_category, tr("hotkey_Topdown", "Toggle UI"));
    lock_camera.setLabel(localized_category, tr("hotkey_Topdown", "Camera lock"));
    previous_player_ship.setLabel(localized_category, tr("hotkey_Topdown", "Cycle previous player ship"));
    next_player_ship.setLabel(localized_category, tr("hotkey_Topdown", "Cycle next player ship"));
    pan_up.setLabel(localized_category, tr("hotkey_Topdown", "Pan up"));
    pan_down.setLabel(localized_category, tr("hotkey_Topdown", "Pan down"));
    pan_left.setLabel(localized_category, tr("hotkey_Topdown", "Pan left"));
    pan_right.setLabel(localized_category, tr("hotkey_Topdown", "Pan right"));
}

Keys::Keys() :
    //Basic
    pause("PAUSE", "P"),
    help("HELP", "F1"),
    escape("ESCAPE", {"Escape", "Home", "Keypad 7", "AC Back"}),
    zoom_in("ZOOM_IN", {"wheel:y"}),
    zoom_out("ZOOM_OUT"),
    voice_all("VOICE_ALL", "Backspace"),
    voice_ship("VOICE_SHIP"),

    //General
    next_station("STATION_NEXT", "Tab"),
    prev_station("STATION_PREVIOUS"),
    station_helms("STATION_HELMS", "F2"),
    station_weapons("STATION_WEAPONS", "F3"),
    station_engineering("STATION_ENGINEERING", "F4"),
    station_science("STATION_SCIENCE", "F5"),
    station_relay("STATION_RELAY", "F6"),

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
    helms_increase_impulse_1("HELMS_IMPULSE_INCREASE_1"),
    helms_increase_impulse_10("HELMS_IMPULSE_INCREASE_10"),
    helms_decrease_impulse("HELMS_IMPULSE_DECREASE", "Down"),
    helms_decrease_impulse_1("HELMS_IMPULSE_DECREASE_1"),
    helms_decrease_impulse_10("HELMS_IMPULSE_DECREASE_10"),
    helms_set_impulse("HELMS_SET_IMPULSE", {"joy:0:axis:1", "gamecontroller:0:axis:lefty"}),
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
    science_scan_abort("SCIENCE_SCAN_ABORT", "D"),
    science_select_next_scannable("SCIENCE_SELECT_NEXT_SCANNABLE", "C"),
    science_scan_param_increase{{
        {"SCIENCE_SCAN_PARAM_INCREASE_1"},
        {"SCIENCE_SCAN_PARAM_INCREASE_2"},
        {"SCIENCE_SCAN_PARAM_INCREASE_3"},
        {"SCIENCE_SCAN_PARAM_INCREASE_4"},
    }},
    science_scan_param_decrease{{
        {"SCIENCE_SCAN_PARAM_DECREASE_1"},
        {"SCIENCE_SCAN_PARAM_DECREASE_2"},
        {"SCIENCE_SCAN_PARAM_DECREASE_3"},
        {"SCIENCE_SCAN_PARAM_DECREASE_4"},
    }},
    science_scan_param_set{{
        {"SCIENCE_SCAN_PARAM_SET_1"},
        {"SCIENCE_SCAN_PARAM_SET_2"},
        {"SCIENCE_SCAN_PARAM_SET_3"},
        {"SCIENCE_SCAN_PARAM_SET_4"},
    }},

    //Engineering
    engineering_select_system{
        {"ENGINEERING_SELECT_SYSTEM_REACTOR", "1"},
        {"ENGINEERING_SELECT_SYSTEM_BEAM_WEAPONS", "2"},
        {"ENGINEERING_SELECT_SYSTEM_MISSILE", "3"},
        {"ENGINEERING_SELECT_SYSTEM_MANEUVERING", "4"},
        {"ENGINEERING_SELECT_SYSTEM_IMPULSE", "5"},
        {"ENGINEERING_SELECT_SYSTEM_WARP", "6"},
        {"ENGINEERING_SELECT_SYSTEM_JUMP_DRIVE", "7"},
        {"ENGINEERING_SELECT_SYSTEM_FRONT_SHIELD", "8"},
        {"ENGINEERING_SELECT_SYSTEM_READ_SHIELD", "9"},
    },
    engineering_select_system_next("ENGINEERING_SELECT_SYSTEM_NEXT", "Keypad +"),
    engineering_select_system_prev("ENGINEERING_SELECT_SYSTEM_PREV", "Keypad -"),
    engineering_set_power_000("ENGINEERING_POWER_000"),
    engineering_set_power_030("ENGINEERING_POWER_030"),
    engineering_set_power_050("ENGINEERING_POWER_050"),
    engineering_set_power_100("ENGINEERING_POWER_100", "\\"),
    engineering_set_power_150("ENGINEERING_POWER_150"),
    engineering_set_power_200("ENGINEERING_POWER_200"),
    engineering_set_power_250("ENGINEERING_POWER_250"),
    engineering_set_power_300("ENGINEERING_POWER_300"),
    engineering_increase_power("ENGINEERING_POWER_INCREASE", "]"),
    engineering_decrease_power("ENGINEERING_POWER_DECREASE", "["),
    engineering_set_power("ENGINEERING_POWER_SET"),
    engineering_increase_coolant("ENGINEERING_COOLANT_INCREASE", "="),
    engineering_decrease_coolant("ENGINEERING_COOLANT_DECREASE", "-"),
    engineering_set_coolant("ENGINEERING_COOLANT_SET"),
    engineering_next_repair_crew("ENGINEERING_REPAIR_CREW_NEXT", "C"),
    engineering_repair_crew_up("ENGINEERING_REPAIR_CREW_UP", "Up"),
    engineering_repair_crew_down("ENGINEERING_REPAIR_CREW_DOWN", "Down"),
    engineering_repair_crew_left("ENGINEERING_REPAIR_CREW_LEFT", "Left"),
    engineering_repair_crew_right("ENGINEERING_REPAIR_CREW_RIGHT", "Right"),
    engineering_self_destruct_start("ENGINEERING_SELF_DESTRUCT_START"),
    engineering_self_destruct_confirm("ENGINEERING_SELF_DESTRUCT_CONFIRM"),
    engineering_self_destruct_cancel("ENGINEERING_SELF_DESTRUCT_CANCEL"),
    engineering_set_power_for_system{
        {"ENGINEERING_SET_SYSTEM_POWER_REACTOR"},
        {"ENGINEERING_SET_SYSTEM_POWER_BEAM_WEAPONS"},
        {"ENGINEERING_SET_SYSTEM_POWER_MISSILE"},
        {"ENGINEERING_SET_SYSTEM_POWER_MANEUVERING"},
        {"ENGINEERING_SET_SYSTEM_POWER_IMPULSE"},
        {"ENGINEERING_SET_SYSTEM_POWER_WARP"},
        {"ENGINEERING_SET_SYSTEM_POWER_JUMP_DRIVE"},
        {"ENGINEERING_SET_SYSTEM_POWER_FRONT_SHIELD"},
        {"ENGINEERING_SET_SYSTEM_POWER_READ_SHIELD"},
    },
    engineering_set_coolant_for_system{
        {"ENGINEERING_SET_SYSTEM_COOLANT_REACTOR"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_BEAM_WEAPONS"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_MISSILE"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_MANEUVERING"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_IMPULSE"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_WARP"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_JUMP_DRIVE"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_FRONT_SHIELD"},
        {"ENGINEERING_SET_SYSTEM_COOLANT_READ_SHIELD"},
    },

    relay_alert_level_none("RELAY_ALERT_NONE"),
    relay_alert_level_yellow("RELAY_ALERT_YELLOW"),
    relay_alert_level_red("RELAY_ALERT_RED"),

    gm_delete("GM_DELETE", "Delete"),
    gm_clipboardcopy("GM_CLIPBOARD_COPY", "F5"),

    spectator_show_callsigns("SPECTATOR_SHOW_CALLSIGNS", "C"),

    debug_modifier("DEBUG_MODIFIER", "Left Ctrl"),
    debug_show_fps("DEBUG_SHOW_FPS", "F10"),
    debug_show_timing("DEBUG_SHOW_TIMING", "F11")
{
}

void Keys::init()
{
    pause.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Pause game"));
    help.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Show in-game help"));
    escape.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Return to ship options menu"));
    zoom_in.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Zoom in on zoomable stations"));
    zoom_out.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Zoom out on zoomable stations"));
    voice_all.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Broadcast voice chat to server"));
    voice_ship.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Broadcast voice chat to ship"));
    fullscreen_key.setLabel(tr("hotkey_menu", "Basic"), tr("hotkey_Basic", "Fullscreen toggle"));

    //General
    next_station.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to next crew station"));
    prev_station.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to previous crew station"));
    station_helms.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to helms station"));
    station_weapons.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to weapons station"));
    station_engineering.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to engineering station"));
    station_science.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to science station"));
    station_relay.setLabel(tr("hotkey_menu", "General"), tr("hotkey_General", "Switch to relay station"));

    //Main screen
    mainscreen_forward.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View forward"));
    mainscreen_left.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View left"));
    mainscreen_right.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View right"));
    mainscreen_back.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View backward"));
    mainscreen_target.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "Lock view on weapons target"));
    mainscreen_tactical_radar.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View tactical radar"));
    mainscreen_long_range_radar.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "View long-range radar"));
    mainscreen_first_person.setLabel(tr("hotkey_menu", "Main Screen"), tr("hotkey_MainScreen", "Toggle first-person view"));

    //helms
    helms_increase_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Increase impulse"));
    helms_increase_impulse_1.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Increase impulse 1%"));
    helms_increase_impulse_10.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Increase impulse 10%"));
    helms_decrease_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Decrease impulse"));
    helms_decrease_impulse_1.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Decrease impulse 1%"));
    helms_decrease_impulse_10.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Decrease impulse 10%"));
    helms_set_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Set impulse (joystick)"));
    helms_zero_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Zero impulse"));
    helms_max_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Max impulse"));
    helms_min_impulse.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Max reverse impulse"));
    helms_turn_left.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Turn left"));
    helms_turn_right.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Turn right"));
    helms_warp0.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Warp off"));
    helms_warp1.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Warp 1"));
    helms_warp2.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Warp 2"));
    helms_warp3.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Warp 3"));
    helms_warp4.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Warp 4"));
    helms_increase_warp.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Increase Warp"));
    helms_decrease_warp.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Decrease Warp"));
    helms_dock_action.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Dock request/abort/undock"));
    helms_dock_request.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Initiate docking"));
    helms_dock_abort.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Abort docking"));
    helms_undock.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Undock"));
    helms_increase_jump_distance.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Increase jump distance"));
    helms_decrease_jump_distance.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Decrease jump distance"));
    helms_execute_jump.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Initiate jump"));
    helms_combat_left.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Combat boost left"));
    helms_combat_right.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Combat boost right"));
    helms_combat_boost.setLabel(tr("hotkey_menu", "Helms"), tr("hotkey_Helms", "Combat boost forwards"));

    //weapons
    weapons_select_homing.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select homing"));
    weapons_select_nuke.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select nuke"));
    weapons_select_mine.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select mine"));
    weapons_select_emp.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select EMP"));
    weapons_select_hvli.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select HVLI"));
    for(auto n = 0u; n < weapons_load_tube.size(); n++)
    {
        weapons_load_tube[n].setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Load tube {number}").format({{"number", string(n+1)}}));
        weapons_unload_tube[n].setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Unload tube {number}").format({{"number", string(n+1)}}));
        weapons_fire_tube[n].setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Fire tube {number}").format({{"number", string(n+1)}}));
    }
    weapons_enemy_next_target.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select next hostile target"));
    weapons_next_target.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Select next target (any)"));
    weapons_toggle_shields.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Toggle shields"));
    weapons_enable_shields.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Enable shields"));
    weapons_disable_shields.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Disable shields"));
    weapons_shield_calibration_increase.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Increase shield frequency target"));
    weapons_shield_calibration_decrease.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Decrease shield frequency target"));
    weapons_shield_calibration_start.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Start shield calibration"));
    weapons_beam_subsystem_target_next.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Next beam subsystem target type"));
    weapons_beam_subsystem_target_previous.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Previous beam subsystem target type"));
    weapons_beam_frequence_increase.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Increase beam frequency"));
    weapons_beam_frequence_decrease.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Decrease beam frequency"));
    weapons_toggle_aim_lock.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Toggle missile aim lock"));
    weapons_enable_aim_lock.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Enable missile aim lock"));
    weapons_disable_aim_lock.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Disable missile aim lock"));
    weapons_aim_left.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Turn missile aim to the left"));
    weapons_aim_right.setLabel(tr("hotkey_menu", "Weapons"), tr("hotkey_Weapons", "Turn missile aim to the right"));

    //Science
    science_scan_object.setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Scan object"));
    science_scan_abort.setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Abort scan"));
    science_select_next_scannable.setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Select next scannable object"));
    for(auto n = 0u; n < science_scan_param_increase.size(); n++)
    {
        science_scan_param_increase[n].setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Scanning parameter {number} increase").format({{"number", string(n+1)}}));
        science_scan_param_decrease[n].setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Scanning parameter {number} decrease").format({{"number", string(n+1)}}));
        science_scan_param_set[n].setLabel(tr("hotkey_menu", "Science"), tr("hotkey_Science", "Set scanning parameter {number} (joystick)").format({{"number", string(n+1)}}));
    }

    //Engineering
    engineering_select_system[static_cast<int>(ShipSystem::Type::Reactor)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select reactor system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::BeamWeapons)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select beam weapon system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::MissileSystem)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select missile weapon system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::Maneuver)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select maneuvering system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::Impulse)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select impulse system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::Warp)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select warp system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::JumpDrive)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select jump drive system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::FrontShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select front shields system"));
    engineering_select_system[static_cast<int>(ShipSystem::Type::RearShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select rear shields system"));
    engineering_select_system_next.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select next system"));
    engineering_select_system_prev.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Select previous system"));
    engineering_set_power_000.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 0%"));
    engineering_set_power_030.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 30%"));
    engineering_set_power_050.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 50%"));
    engineering_set_power_100.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 100%"));
    engineering_set_power_150.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 150%"));
    engineering_set_power_200.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 200%"));
    engineering_set_power_250.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 250%"));
    engineering_set_power_300.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power to 300%"));
    engineering_increase_power.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Increase system power"));
    engineering_decrease_power.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Decrease system power"));
    engineering_set_power.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system power (joystick)"));
    engineering_increase_coolant.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Increase system coolant"));
    engineering_decrease_coolant.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Decrease system coolant"));
    engineering_set_coolant.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set system coolant (joystick)"));
    engineering_next_repair_crew.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Next repair crew"));
    engineering_repair_crew_up.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Crew move up"));
    engineering_repair_crew_down.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Crew move down"));
    engineering_repair_crew_left.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Crew move left"));
    engineering_repair_crew_right.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Crew move right"));
    engineering_self_destruct_start.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Start self-destruct"));
    engineering_self_destruct_confirm.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Confirm self-destruct"));
    engineering_self_destruct_cancel.setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Cancel self-destruct"));

    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::Reactor)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set reactor power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::BeamWeapons)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set beam weapon power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::MissileSystem)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set missile weapon power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::Maneuver)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set maneuvering power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::Impulse)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set impulse power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::Warp)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set warp power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::JumpDrive)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set jump drive power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::FrontShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set front shields power (joystick)"));
    engineering_set_power_for_system[static_cast<int>(ShipSystem::Type::RearShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set rear shields power (joystick)"));

    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::Reactor)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set reactor coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::BeamWeapons)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set beam weapon coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::MissileSystem)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set missile weapon coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::Maneuver)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set maneuvering coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::Impulse)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set impulse coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::Warp)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set warp coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::JumpDrive)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set jump drive coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::FrontShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set front shields coolant (joystick)"));
    engineering_set_coolant_for_system[static_cast<int>(ShipSystem::Type::RearShield)].setLabel(tr("hotkey_menu", "Engineering"), tr("hotkey_Engineering", "Set rear shields coolant (joystick)"));

    relay_alert_level_none.setLabel(tr("hotkey_menu", "Relay"), tr("hotkey_Relay", "Alert level: Normal"));
    relay_alert_level_yellow.setLabel(tr("hotkey_menu", "Relay"), tr("hotkey_Relay", "Alert level: Yellow"));
    relay_alert_level_red.setLabel(tr("hotkey_menu", "Relay"), tr("hotkey_Relay", "Alert level: Red"));

    cinematic.init();
    topdown.init();
    //GM
    gm_delete.setLabel(tr("hotkey_menu", "GM"), tr("hotkey_GM", "Delete"));
    gm_clipboardcopy.setLabel(tr("hotkey_menu", "GM"), tr("hotkey_GM", "Copy to clipboard"));

    //Various
    spectator_show_callsigns.setLabel(tr("hotkey_menu", "Various"), tr("hotkey_various", "Show callsigns (spectator)"));

    //Debug
    debug_show_fps.setLabel(tr("hotkey_menu", "Various"), tr("hotkey_debug", "Show FPS"));
    debug_show_timing.setLabel(tr("hotkey_menu", "Various"), tr("hotkey_debug", "Show debug timing"));
}
