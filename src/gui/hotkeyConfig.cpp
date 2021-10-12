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
    weapons_load_tube1("WEAPONS_LOAD_TUBE1"),
    weapons_load_tube2("WEAPONS_LOAD_TUBE2"),
    weapons_load_tube3("WEAPONS_LOAD_TUBE3"),
    weapons_load_tube4("WEAPONS_LOAD_TUBE4"),
    weapons_load_tube5("WEAPONS_LOAD_TUBE5"),
    weapons_load_tube6("WEAPONS_LOAD_TUBE6"),
    weapons_load_tube7("WEAPONS_LOAD_TUBE7"),
    weapons_load_tube8("WEAPONS_LOAD_TUBE8"),
    weapons_load_tube9("WEAPONS_LOAD_TUBE9"),
    weapons_load_tube10("WEAPONS_LOAD_TUBE10"),
    weapons_load_tube11("WEAPONS_LOAD_TUBE11"),
    weapons_load_tube12("WEAPONS_LOAD_TUBE12"),
    weapons_load_tube13("WEAPONS_LOAD_TUBE13"),
    weapons_load_tube14("WEAPONS_LOAD_TUBE14"),
    weapons_load_tube15("WEAPONS_LOAD_TUBE15"),
    weapons_load_tube16("WEAPONS_LOAD_TUBE16"),
    weapons_unload_tube1("WEAPONS_UNLOAD_TUBE1"),
    weapons_unload_tube2("WEAPONS_UNLOAD_TUBE2"),
    weapons_unload_tube3("WEAPONS_UNLOAD_TUBE3"),
    weapons_unload_tube4("WEAPONS_UNLOAD_TUBE4"),
    weapons_unload_tube5("WEAPONS_UNLOAD_TUBE5"),
    weapons_unload_tube6("WEAPONS_UNLOAD_TUBE6"),
    weapons_unload_tube7("WEAPONS_UNLOAD_TUBE7"),
    weapons_unload_tube8("WEAPONS_UNLOAD_TUBE8"),
    weapons_unload_tube9("WEAPONS_UNLOAD_TUBE9"),
    weapons_unload_tube10("WEAPONS_UNLOAD_TUBE10"),
    weapons_unload_tube11("WEAPONS_UNLOAD_TUBE11"),
    weapons_unload_tube12("WEAPONS_UNLOAD_TUBE12"),
    weapons_unload_tube13("WEAPONS_UNLOAD_TUBE13"),
    weapons_unload_tube14("WEAPONS_UNLOAD_TUBE14"),
    weapons_unload_tube15("WEAPONS_UNLOAD_TUBE15"),
    weapons_unload_tube16("WEAPONS_UNLOAD_TUBE16"),
    weapons_fire_tube1("WEAPONS_FIRE_TUBE1"),
    weapons_fire_tube2("WEAPONS_FIRE_TUBE2"),
    weapons_fire_tube3("WEAPONS_FIRE_TUBE3"),
    weapons_fire_tube4("WEAPONS_FIRE_TUBE4"),
    weapons_fire_tube5("WEAPONS_FIRE_TUBE5"),
    weapons_fire_tube6("WEAPONS_FIRE_TUBE6"),
    weapons_fire_tube7("WEAPONS_FIRE_TUBE7"),
    weapons_fire_tube8("WEAPONS_FIRE_TUBE8"),
    weapons_fire_tube9("WEAPONS_FIRE_TUBE9"),
    weapons_fire_tube10("WEAPONS_FIRE_TUBE10"),
    weapons_fire_tube11("WEAPONS_FIRE_TUBE11"),
    weapons_fire_tube12("WEAPONS_FIRE_TUBE12"),
    weapons_fire_tube13("WEAPONS_FIRE_TUBE13"),
    weapons_fire_tube14("WEAPONS_FIRE_TUBE14"),
    weapons_fire_tube15("WEAPONS_FIRE_TUBE15"),
    weapons_fire_tube16("WEAPONS_FIRE_TUBE16"),
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

static std::vector<std::pair<string, SDL_Keycode> > sfml_key_names = {
    /*
    {"A", sf::Keyboard::A},
    {"B", sf::Keyboard::B},
    {"C", sf::Keyboard::C},
    {"D", sf::Keyboard::D},
    {"E", sf::Keyboard::E},
    {"F", sf::Keyboard::F},
    {"G", sf::Keyboard::G},
    {"H", sf::Keyboard::H},
    {"I", sf::Keyboard::I},
    {"J", sf::Keyboard::J},
    {"K", sf::Keyboard::K},
    {"L", sf::Keyboard::L},
    {"M", sf::Keyboard::M},
    {"N", sf::Keyboard::N},
    {"O", sf::Keyboard::O},
    {"P", sf::Keyboard::P},
    {"Q", sf::Keyboard::Q},
    {"R", sf::Keyboard::R},
    {"S", sf::Keyboard::S},
    {"T", sf::Keyboard::T},
    {"U", sf::Keyboard::U},
    {"V", sf::Keyboard::V},
    {"W", sf::Keyboard::W},
    {"X", sf::Keyboard::X},
    {"Y", sf::Keyboard::Y},
    {"Z", sf::Keyboard::Z},
    {"Num0", sf::Keyboard::Num0},
    {"Num1", sf::Keyboard::Num1},
    {"Num2", sf::Keyboard::Num2},
    {"Num3", sf::Keyboard::Num3},
    {"Num4", sf::Keyboard::Num4},
    {"Num5", sf::Keyboard::Num5},
    {"Num6", sf::Keyboard::Num6},
    {"Num7", sf::Keyboard::Num7},
    {"Num8", sf::Keyboard::Num8},
    {"Num9", sf::Keyboard::Num9},
    {"Escape", sf::Keyboard::Escape},
    {"LControl", sf::Keyboard::LControl},
    {"LShift", sf::Keyboard::LShift},
    {"LAlt", sf::Keyboard::LAlt},
    {"LSystem", sf::Keyboard::LSystem},
    {"RControl", sf::Keyboard::RControl},
    {"RShift", sf::Keyboard::RShift},
    {"RAlt", sf::Keyboard::RAlt},
    {"RSystem", sf::Keyboard::RSystem},
    {"Menu", sf::Keyboard::Menu},
    {"LBracket", sf::Keyboard::LBracket},
    {"RBracket", sf::Keyboard::RBracket},
    {"SemiColon", sf::Keyboard::SemiColon},
    {"Comma", sf::Keyboard::Comma},
    {"Period", sf::Keyboard::Period},
    {"Quote", sf::Keyboard::Quote},
    {"Slash", sf::Keyboard::Slash},
    {"BackSlash", sf::Keyboard::BackSlash},
    {"Tilde", sf::Keyboard::Tilde},
    {"Equal", sf::Keyboard::Equal},
    {"Dash", sf::Keyboard::Dash},
    {"Space", sf::Keyboard::Space},
    {"Return", sf::Keyboard::Return},
    {"BackSpace", sf::Keyboard::BackSpace},
    {"Tab", sf::Keyboard::Tab},
    {"PageUp", sf::Keyboard::PageUp},
    {"PageDown", sf::Keyboard::PageDown},
    {"End", sf::Keyboard::End},
    {"Home", sf::Keyboard::Home},
    {"Insert", sf::Keyboard::Insert},
    {"Delete", sf::Keyboard::Delete},
    {"Add", sf::Keyboard::Add},
    {"Subtract", sf::Keyboard::Subtract},
    {"Multiply", sf::Keyboard::Multiply},
    {"Divide", sf::Keyboard::Divide},
    {"Left", sf::Keyboard::Left},
    {"Right", sf::Keyboard::Right},
    {"Up", sf::Keyboard::Up},
    {"Down", sf::Keyboard::Down},
    {"Numpad0", sf::Keyboard::Numpad0},
    {"Numpad1", sf::Keyboard::Numpad1},
    {"Numpad2", sf::Keyboard::Numpad2},
    {"Numpad3", sf::Keyboard::Numpad3},
    {"Numpad4", sf::Keyboard::Numpad4},
    {"Numpad5", sf::Keyboard::Numpad5},
    {"Numpad6", sf::Keyboard::Numpad6},
    {"Numpad7", sf::Keyboard::Numpad7},
    {"Numpad8", sf::Keyboard::Numpad8},
    {"Numpad9", sf::Keyboard::Numpad9},
    {"F1", sf::Keyboard::F1},
    {"F2", sf::Keyboard::F2},
    {"F3", sf::Keyboard::F3},
    {"F4", sf::Keyboard::F4},
    {"F5", sf::Keyboard::F5},
    {"F6", sf::Keyboard::F6},
    {"F7", sf::Keyboard::F7},
    {"F8", sf::Keyboard::F8},
    {"F9", sf::Keyboard::F9},
    {"F10", sf::Keyboard::F10},
    {"F11", sf::Keyboard::F11},
    {"F12", sf::Keyboard::F12},
    {"F13", sf::Keyboard::F13},
    {"F14", sf::Keyboard::F14},
    {"F15", sf::Keyboard::F15},
    {"Pause", sf::Keyboard::Pause},
    */
};

string HotkeyConfig::getStringForKey(SDL_Keycode key) const
{
    for(const auto& key_name : sfml_key_names)
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
    std::vector<HotkeyResult> results;
    for(const HotkeyConfigCategory& cat : categories)
    {
        for(const HotkeyConfigItem& item : cat.hotkeys)
        {
            if (item.hotkey.keysym.sym == key.keysym.sym && item.hotkey.keysym.mod == key.keysym.mod)
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
                for(auto key_name : sfml_key_names)
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
            for(auto key_name : sfml_key_names)
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
    for (const auto& sfml_key : sfml_key_names)
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
